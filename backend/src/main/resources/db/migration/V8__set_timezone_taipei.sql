-- ============================================================
-- V8: 資料庫預設時區設為 Asia/Taipei (UTC+8)
-- 欄位是 TIMESTAMPTZ（存的是時間點，內部 UTC，資料不變）；
-- 這裡只改「顯示時區」→ 新連線（DataGrip / 後端 / psql）一律以 +08 呈現。
-- 用 current_database() 動態組，prod 換 DB 名也適用。
-- 注意：ALTER DATABASE SET 只對「之後的新連線」生效，當前連線不變。
-- ============================================================
DO $$
BEGIN
    EXECUTE format('ALTER DATABASE %I SET timezone TO %L', current_database(), 'Asia/Taipei');
END $$;
