-- ============================================================
-- V4: get_survey — 回傳現行版問卷定義（給前端 build-time inline）
-- 選版策略（決定 B）：每個 sortOrder 取「createDate 最新」那列，
--   不靠 version 數字、不需 active 欄；只有一版時行為等同「全選」。
-- 回傳 JSONB：{ "questions": [ { ...題目, "answers":[ ...選項 ] } ] }
-- 純文字題（Q8/Q11）answers 為 []
-- ============================================================
CREATE OR REPLACE FUNCTION get_survey()
RETURNS JSONB AS $$
DECLARE
    v_result JSONB;
BEGIN
    WITH "currentQ" AS (
        SELECT DISTINCT ON ("sortOrder") *
        FROM "question"
        ORDER BY "sortOrder", "createDate" DESC
    )
    SELECT jsonb_build_object(
        'questions',
        COALESCE(
            jsonb_agg(
                jsonb_build_object(
                    'questionId', q."id",
                    'sortOrder',  q."sortOrder",
                    'version',    q."version",
                    'labelZh',    q."labelZh",
                    'labelEn',    q."labelEn",
                    'hintZh',     q."hintZh",
                    'hintEn',     q."hintEn",
                    'tagZh',      q."tagZh",
                    'tagEn',      q."tagEn",
                    'answers',    COALESCE((
                        SELECT jsonb_agg(
                            jsonb_build_object(
                                'answerId',  a."id",
                                'sortOrder', a."sortOrder",
                                'labelZh',   a."labelZh",
                                'labelEn',   a."labelEn"
                            ) ORDER BY a."sortOrder"
                        )
                        FROM "answer" a
                        WHERE a."questionId" = q."id"
                    ), '[]'::jsonb)
                ) ORDER BY q."sortOrder"
            ),
            '[]'::jsonb
        )
    )
    INTO v_result
    FROM "currentQ" q;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql;
