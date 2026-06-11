-- ============================================================
-- V6: submit_survey 擴充 — 同交易寫入訪談意願（opt-in）
-- 改簽章需 DROP 再 CREATE（CREATE OR REPLACE 不能改參數列）
-- p_interview：{ "name": "...", "email": "..." }；NULL 或無 email = 沒勾訪談
-- PII（name/email）寫進獨立的 SurveyInterview，分享資料時可排除
-- ============================================================
DROP FUNCTION submit_survey(varchar, text, jsonb);

CREATE FUNCTION submit_survey(
    p_locale       varchar,
    p_userAgent    text,
    p_items        jsonb,
    p_interview    jsonb DEFAULT NULL
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

    -- 訪談意願（有 email 才寫；name 缺值補空字串避免 NOT NULL 衝突）
    IF p_interview IS NOT NULL
       AND COALESCE(p_interview->>'email', '') <> '' THEN
        INSERT INTO "SurveyInterview"("surveyMainId","name","email")
        VALUES (
            v_mainId,
            COALESCE(p_interview->>'name', ''),
            p_interview->>'email'
        );
    END IF;

    RETURN v_mainId;
END;
$$ LANGUAGE plpgsql;
