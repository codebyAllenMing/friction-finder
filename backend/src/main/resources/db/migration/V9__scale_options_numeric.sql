-- ============================================================
-- V9: Q9 / Q10 量表選項 label 改為純數字（1~5）
-- 兩端錨點文字（完全沒訊息 / 非常明確 / 非常不好 / 非常好）已移到前端 i18n 固定顯示，
-- 故 DB 選項值只保留數字，提交資料（SurveyItemDetail.answerLabel）也更乾淨。
-- 用 sortOrder join 定位，與實際 id 無關 → dev / prod 皆適用。
-- 既有提交不受影響（answerLabel 是送出當下的快照）。
-- ============================================================
UPDATE "answer" a
SET "labelZh" = a."sortOrder"::text,
    "labelEn" = a."sortOrder"::text
FROM "question" q
WHERE a."questionId" = q."id"
  AND q."sortOrder" IN (9, 10);
