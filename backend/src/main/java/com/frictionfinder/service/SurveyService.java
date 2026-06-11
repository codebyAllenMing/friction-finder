package com.frictionfinder.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.frictionfinder.dto.SubmitRequest;
import com.frictionfinder.repository.SurveyRepository;
import org.springframework.stereotype.Service;

@Service
public class SurveyService {

    private final SurveyRepository repo;
    private final ObjectMapper mapper;

    public SurveyService(SurveyRepository repo, ObjectMapper mapper) {
        this.repo = repo;
        this.mapper = mapper;
    }

    /** 現行版問卷定義（JSON 字串，原樣回給前端）。 */
    public String getSurvey() {
        return repo.getSurvey();
    }

    /** 一筆提交：items（+ 選填 interview）序列化成 JSON 交給 submit_survey()，回傳 SurveyMain.id。 */
    public Long submit(SubmitRequest req, String userAgent) {
        try {
            String itemsJson = mapper.writeValueAsString(req.items());
            String interviewJson = req.interview() != null
                    ? mapper.writeValueAsString(req.interview())
                    : null;
            return repo.submitSurvey(req.locale(), userAgent, itemsJson, interviewJson);
        } catch (JsonProcessingException e) {
            throw new IllegalArgumentException("payload 序列化失敗", e);
        }
    }
}
