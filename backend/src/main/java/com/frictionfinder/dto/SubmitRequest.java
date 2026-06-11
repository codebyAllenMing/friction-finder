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
    // 只收 id；題目/答案文字（label）由 submit_survey() 用 id 從 question/answer 表查，寫進快照欄。
    public record Item(
            Long questionId,
            List<Answer> answers
    ) {}

    public record Answer(
            Long answerId,        // 純文字題為 null
            String responseText   // 「其他」補充 / 開放題回答
    ) {}

    public record Interview(
            String name,
            String email
    ) {}
}
