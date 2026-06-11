package com.frictionfinder.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

/**
 * SP-driven 資料存取：所有讀寫都呼叫 Postgres function，不用 ORM。
 */
@Repository
public class SurveyRepository {

    private final JdbcTemplate jdbc;

    public SurveyRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    /** 呼叫 get_survey()，回傳現行版問卷定義（JSON 字串）。 */
    public String getSurvey() {
        return jdbc.queryForObject("SELECT get_survey()", String.class);
    }

    /**
     * 呼叫 submit_survey()，寫入主-附-細（+ opt-in 訪談），回傳新的 SurveyMain.id。
     * interviewJson 為 null 代表沒勾訪談。
     */
    public Long submitSurvey(String locale, String userAgent, String itemsJson, String interviewJson) {
        return jdbc.queryForObject(
                "SELECT submit_survey(?, ?, ?::jsonb, ?::jsonb)",
                Long.class,
                locale, userAgent, itemsJson, interviewJson);
    }
}
