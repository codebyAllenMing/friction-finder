-- ============================================================
-- V1: Lookup 表（題目定義 / 答案定義）
-- 命名：Table 小寫、column camelCase（用 "" 保留大小寫）
-- FK 只做語意關聯，不加 REFERENCES constraint（integrity 由 SP / app 負責）
-- ============================================================

-- 題目定義
CREATE TABLE "question" (
    "id"           BIGSERIAL PRIMARY KEY,
    "sortOrder"    INT NOT NULL,
    "version"      TEXT NOT NULL DEFAULT '1',
    "labelZh"      TEXT NOT NULL,
    "labelEn"      TEXT NOT NULL,
    "hintZh"       TEXT,
    "hintEn"       TEXT,
    "tagZh"        TEXT[],
    "tagEn"        TEXT[],
    "createDate"   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 答案定義（每題自己的選項組；純文字題如 Q8/Q11 無 answer）
CREATE TABLE "answer" (
    "id"          BIGSERIAL PRIMARY KEY,
    "questionId"  BIGINT NOT NULL,         -- 語意指向 question.id
    "sortOrder"   INT,
    "labelZh"     TEXT,
    "labelEn"     TEXT,
    "createDate"  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 索引
CREATE INDEX "idxAnswerQuestionId"   ON "answer"("questionId");
CREATE INDEX "idxQuestionSortOrder"  ON "question"("sortOrder", "version");
