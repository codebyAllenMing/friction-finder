package com.frictionfinder.controller;

import com.frictionfinder.dto.SubmitRequest;
import com.frictionfinder.service.SurveyService;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api")
public class SurveyController {

    private final SurveyService service;

    public SurveyController(SurveyService service) {
        this.service = service;
    }

    /** 問卷定義（前端 build-time inline 抓這支）。 */
    @GetMapping(value = "/survey", produces = MediaType.APPLICATION_JSON_VALUE)
    public String getSurvey() {
        return service.getSurvey();
    }

    /** 送出一筆問卷。 */
    @PostMapping(value = "/responses", produces = MediaType.APPLICATION_JSON_VALUE)
    public Map<String, Long> submit(
            @RequestBody SubmitRequest req,
            @RequestHeader(value = "User-Agent", required = false) String userAgent) {
        Long mainId = service.submit(req, userAgent);
        return Map.of("surveyMainId", mainId);
    }
}
