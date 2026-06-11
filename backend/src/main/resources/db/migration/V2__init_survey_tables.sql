-- ============================================================
-- V2: 提交資料表（主-附-細 + 訪談）
-- 主-附-細：SurveyMain 1──< SurveyItem 1──< SurveyItemDetail
-- SurveyInterview：PII 隔離，opt-in 才有資料
-- ============================================================

-- 主檔：一次提交一筆
CREATE TABLE "SurveyMain" (
    "id"          BIGSERIAL PRIMARY KEY,
    "locale"      VARCHAR(5) NOT NULL,
    "userAgent"   TEXT,
    "createDate"  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 附檔：每題答題一筆（含送出當下的題目文字快照）
CREATE TABLE "SurveyItem" (
    "id"             BIGSERIAL PRIMARY KEY,
    "surveyMainId"   BIGINT NOT NULL,        -- 語意指向 SurveyMain.id
    "questionId"     BIGINT NOT NULL,        -- 語意指向 question.id
    "questionLabel"  TEXT NOT NULL,          -- 題目文字快照
    "createDate"     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 細節：每個答案值一筆（複選多筆、單選一筆、純文字一筆）
CREATE TABLE "SurveyItemDetail" (
    "id"            BIGSERIAL PRIMARY KEY,
    "surveyItemId"  BIGINT NOT NULL,         -- 語意指向 SurveyItem.id
    "answerId"      BIGINT,                  -- 純文字題（無預設選項）為 NULL
    "answerLabel"   TEXT,                    -- 答案文字快照
    "responseText"  TEXT                     -- 使用者自填（「其他」補充 / 開放題）
);

-- 訪談意願（PII 隔離）
CREATE TABLE "SurveyInterview" (
    "id"            BIGSERIAL PRIMARY KEY,
    "surveyMainId"  BIGINT NOT NULL,         -- 語意指向 SurveyMain.id
    "name"          TEXT NOT NULL,
    "email"         TEXT NOT NULL,
    "createDate"    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 索引
CREATE INDEX "idxSurveyItemMainId"       ON "SurveyItem"("surveyMainId");
CREATE INDEX "idxSurveyItemDetailItemId" ON "SurveyItemDetail"("surveyItemId");
CREATE INDEX "idxSurveyInterviewMainId"  ON "SurveyInterview"("surveyMainId");
