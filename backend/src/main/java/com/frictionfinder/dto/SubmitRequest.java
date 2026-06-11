package com.frictionfinder.dto;

import java.util.List;

/**
 * POST /api/responses 的請求 body。
 * 形狀對齊 submit_survey() 的 p_items / p_interview JSONB。
 */
public record SubmitRequest(
        String locale,
        List<Item> items,
        Interview interview   // 沒勾訪談則為 null
) {
    public record Item(
            Long questionId,
            String questionLabel,
            List<Answer> answers
    ) {}

    public record Answer(
            Long answerId,        // 純文字題為 null
            String answerLabel,   // 純文字題為 null
            String responseText   // 「其他」補充 / 開放題回答
    ) {}

    public record Interview(
            String name,
            String email
    ) {}
}
