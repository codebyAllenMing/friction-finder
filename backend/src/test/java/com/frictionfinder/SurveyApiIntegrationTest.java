package com.frictionfinder;

import com.jayway.jsonpath.JsonPath;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.http.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 整合測試：用 Testcontainers 起一個用完即丟的 Postgres 16，
 * Flyway 自動建 schema + seed，再透過真正的 HTTP（含 filter chain）打 API，
 * 一路驗到 plpgsql SP。
 *
 * 限流是 per-IP 記憶體桶且跨測試不重置，所以每個會打 POST 的測試用各自的
 * X-Forwarded-For，避免互相消耗代幣。
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
class SurveyApiIntegrationTest {

    @Container
    @ServiceConnection
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16");

    @Autowired
    TestRestTemplate rest;

    @Autowired
    JdbcTemplate jdbc;

    @BeforeEach
    void cleanData() {
        // 只清提交資料，保留 question/answer seed
        jdbc.execute("TRUNCATE \"SurveyMain\", \"SurveyItem\", \"SurveyItemDetail\", \"SurveyInterview\" RESTART IDENTITY");
    }

    // ---- helpers ----

    private HttpHeaders headers(String xff, String origin) {
        HttpHeaders h = new HttpHeaders();
        h.setContentType(MediaType.APPLICATION_JSON);
        if (xff != null) h.add("X-Forwarded-For", xff);
        if (origin != null) h.add(HttpHeaders.ORIGIN, origin);
        return h;
    }

    private ResponseEntity<String> post(String body, String xff) {
        return rest.exchange("/api/responses", HttpMethod.POST,
                new HttpEntity<>(body, headers(xff, null)), String.class);
    }

    private int count(String table) {
        return jdbc.queryForObject("SELECT count(*) FROM \"" + table + "\"", Integer.class);
    }

    // ---- 讀路徑 ----

    @Test
    void getSurvey_returns11QuestionsWithAnswers() {
        ResponseEntity<String> res = rest.getForEntity("/api/survey", String.class);

        assertThat(res.getStatusCode()).isEqualTo(HttpStatus.OK);
        String body = res.getBody();
        int questionCount = JsonPath.read(body, "$.questions.length()");
        assertThat(questionCount).isEqualTo(11);

        // questions 依 sortOrder 排序，index 3 = Q4，應有 8 個答案
        int q4Answers = JsonPath.read(body, "$.questions[3].answers.length()");
        assertThat(q4Answers).isEqualTo(8);
    }

    // ---- 寫路徑 ----

    @Test
    void submit_writesMainItemDetail() {
        String body = """
            {
              "locale":"zh",
              "items":[
                {"questionId":4,"questionLabel":"訂票流程","answers":[
                  {"answerId":1,"answerLabel":"選地點"},
                  {"answerId":7,"answerLabel":"付款"},
                  {"answerId":null,"answerLabel":null,"responseText":"找不到航班"}
                ]},
                {"questionId":11,"questionLabel":"開放回饋","answers":[
                  {"answerId":null,"answerLabel":null,"responseText":"整體不錯"}
                ]}
              ]
            }
            """;

        ResponseEntity<String> res = post(body, "10.1.0.1");

        assertThat(res.getStatusCode()).isEqualTo(HttpStatus.OK);
        int mainId = JsonPath.read(res.getBody(), "$.surveyMainId");
        assertThat(mainId).isEqualTo(1);
        assertThat(count("SurveyMain")).isEqualTo(1);
        assertThat(count("SurveyItem")).isEqualTo(2);     // Q4 + Q11
        assertThat(count("SurveyItemDetail")).isEqualTo(4); // 3 + 1
    }

    @Test
    void submit_withInterview_writesPiiRow() {
        String body = """
            {
              "locale":"zh",
              "items":[{"questionId":1,"questionLabel":"Q1","answers":[{"answerId":1,"answerLabel":"有用過"}]}],
              "interview":{"name":"小明","email":"ming@example.com"}
            }
            """;

        ResponseEntity<String> res = post(body, "10.1.0.2");

        assertThat(res.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(count("SurveyInterview")).isEqualTo(1);
        String email = jdbc.queryForObject("SELECT \"email\" FROM \"SurveyInterview\"", String.class);
        assertThat(email).isEqualTo("ming@example.com");
    }

    @Test
    void submit_withoutInterview_noPiiRow() {
        String body = """
            {"locale":"en","items":[{"questionId":1,"questionLabel":"Q1","answers":[{"answerId":2,"answerLabel":"No"}]}]}
            """;

        ResponseEntity<String> res = post(body, "10.1.0.3");

        assertThat(res.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(count("SurveyInterview")).isZero();
    }

    @Test
    void submit_interviewWithEmptyEmail_noPiiRow() {
        String body = """
            {
              "locale":"zh",
              "items":[],
              "interview":{"name":"匿名","email":""}
            }
            """;

        ResponseEntity<String> res = post(body, "10.1.0.4");

        assertThat(res.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(count("SurveyInterview")).isZero();
    }

    // ---- 防護 ----

    @Test
    void evilOrigin_isForbidden() {
        ResponseEntity<String> res = rest.exchange("/api/survey", HttpMethod.GET,
                new HttpEntity<>(headers(null, "http://evil.com")), String.class);
        assertThat(res.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
    }

    @Test
    void whitelistedOrigin_isAllowed() {
        ResponseEntity<String> res = rest.exchange("/api/survey", HttpMethod.GET,
                new HttpEntity<>(headers(null, "http://localhost:5173")), String.class);
        assertThat(res.getStatusCode()).isEqualTo(HttpStatus.OK);
    }

    @Test
    void rateLimit_blocksAfterCapacity() {
        String body = "{\"locale\":\"zh\",\"items\":[]}";
        String ip = "10.9.9.9"; // 專屬 IP，避免影響其他測試

        // 預設 capacity=3：前 3 次 200，第 4、5 次 429
        assertThat(post(body, ip).getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(post(body, ip).getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(post(body, ip).getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(post(body, ip).getStatusCode()).isEqualTo(HttpStatus.TOO_MANY_REQUESTS);
        assertThat(post(body, ip).getStatusCode()).isEqualTo(HttpStatus.TOO_MANY_REQUESTS);
    }
}
