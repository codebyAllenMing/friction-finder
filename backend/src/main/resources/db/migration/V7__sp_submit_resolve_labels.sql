-- ============================================================
-- V7: submit_survey 改為「以 id 查 label」
-- 前端 payload 只送 questionId / answerId（+ responseText），不再帶文字。
-- 題目/答案文字快照改由 SP 用 id 從 question / answer 表查，依 p_locale 取 zh / en。
-- 簽章不變（varchar, text, jsonb, jsonb）→ 用 CREATE OR REPLACE。
-- ============================================================
CREATE OR REPLACE FUNCTION submit_survey(
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
    v_qid     BIGINT;
    v_aid     BIGINT;
    v_qLabel  TEXT;
    v_aLabel  TEXT;
BEGIN
    -- 主檔
    INSERT INTO "SurveyMain"("locale","userAgent")
    VALUES (p_locale, p_userAgent)
    RETURNING "id" INTO v_mainId;

    -- 附檔 + 細節
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items) LOOP
        v_qid := (v_item->>'questionId')::BIGINT;

        -- 題目文字快照：依 locale 取 zh/en
        SELECT CASE WHEN p_locale = 'en' THEN q."labelEn" ELSE q."labelZh" END
        INTO v_qLabel
        FROM "question" q
        WHERE q."id" = v_qid;

        IF v_qLabel IS NULL THEN
            CONTINUE; -- 未知題目 id，略過整題（不寫半筆）
        END IF;

        INSERT INTO "SurveyItem"("surveyMainId","questionId","questionLabel")
        VALUES (v_mainId, v_qid, v_qLabel)
        RETURNING "id" INTO v_itemId;

        FOR v_answer IN SELECT * FROM jsonb_array_elements(COALESCE(v_item->'answers', '[]'::jsonb)) LOOP
            v_aid := NULLIF((v_answer->>'answerId'), '')::BIGINT;

            -- 答案文字快照：純文字題（answerId 為 null）保持 null
            v_aLabel := NULL;
            IF v_aid IS NOT NULL THEN
                SELECT CASE WHEN p_locale = 'en' THEN a."labelEn" ELSE a."labelZh" END
                INTO v_aLabel
                FROM "answer" a
                WHERE a."id" = v_aid;
            END IF;

            INSERT INTO "SurveyItemDetail"("surveyItemId","answerId","answerLabel","responseText")
            VALUES (v_itemId, v_aid, v_aLabel, v_answer->>'responseText');
        END LOOP;
    END LOOP;

    -- 訪談意願（有 email 才寫）
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
