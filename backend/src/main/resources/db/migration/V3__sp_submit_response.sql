-- ============================================================
-- V3: submit_survey — 一次提交寫主-附-細（單一交易）
-- p_items 形狀：
--   [{ "questionId":4, "questionLabel":"...",
--      "answers":[{ "answerId":20, "answerLabel":"選時間", "responseText":null }, ...] }, ...]
-- 純文字題：answerId 給 null / ""，只帶 responseText
-- 回傳：新建的 SurveyMain.id
-- ============================================================
CREATE OR REPLACE FUNCTION submit_survey(
    p_locale       VARCHAR,
    p_userAgent    TEXT,
    p_items        JSONB
) RETURNS BIGINT AS $$
DECLARE
    v_mainId  BIGINT;
    v_itemId  BIGINT;
    v_item    JSONB;
    v_answer  JSONB;
BEGIN
    -- 主檔
    INSERT INTO "SurveyMain"("locale","userAgent")
    VALUES (p_locale, p_userAgent)
    RETURNING "id" INTO v_mainId;

    -- 附檔 + 細節
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items) LOOP
        INSERT INTO "SurveyItem"("surveyMainId","questionId","questionLabel")
        VALUES (v_mainId, (v_item->>'questionId')::BIGINT, v_item->>'questionLabel')
        RETURNING "id" INTO v_itemId;

        FOR v_answer IN SELECT * FROM jsonb_array_elements(COALESCE(v_item->'answers', '[]'::jsonb)) LOOP
            INSERT INTO "SurveyItemDetail"("surveyItemId","answerId","answerLabel","responseText")
            VALUES (
                v_itemId,
                NULLIF((v_answer->>'answerId'), '')::BIGINT,
                v_answer->>'answerLabel',
                v_answer->>'responseText'
            );
        END LOOP;
    END LOOP;

    RETURN v_mainId;
END;
$$ LANGUAGE plpgsql;
