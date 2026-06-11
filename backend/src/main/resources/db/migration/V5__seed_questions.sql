-- ============================================================
-- V5: Seed — question + answer（來源 v4-reference.html）
-- 注意：英文翻譯為初稿，正式上線前請人工 review
-- version 為 TEXT，首版一律 '1'
-- ============================================================

INSERT INTO "question" ("sortOrder","version","labelZh","labelEn","hintZh","hintEn","tagZh","tagEn") VALUES
(1,  '1', '你有用過 STARLUX App 嗎?',
         'Have you used the STARLUX App?',
         NULL, NULL,
         ARRAY['篩選'], ARRAY['Screening']),

(2,  '1', '你最近一次用 STARLUX App,主要是為了什麼?',
         'What was the main purpose of your most recent use of the STARLUX App?',
         NULL, NULL,
         ARRAY['使用情境'], ARRAY['Context']),

(3,  '1', '你實際用過 STARLUX App 完成以下哪些流程?',
         'Which of the following flows have you actually completed using the STARLUX App?',
         '可複選',
         'Multiple selections allowed',
         ARRAY['流程體驗'], ARRAY['Flow Experience']),

(4,  '1', '訂票流程中,哪些步驟覺得不順暢?',
         'Which steps in the booking flow felt unsmooth?',
         '可複選 — 勾選後可選填當時狀況',
         'Multiple selections allowed — optional comment per selection',
         ARRAY['流程體驗','訂票'], ARRAY['Flow Experience','Booking']),

(5,  '1', '改票 / 退票流程中,哪些步驟覺得不順暢?',
         'Which steps in the change/refund flow felt unsmooth?',
         '可複選 — 勾選後可選填當時狀況',
         'Multiple selections allowed — optional comment per selection',
         ARRAY['流程體驗','改退'], ARRAY['Flow Experience','Change']),

(6,  '1', '線上報到流程中,哪些步驟覺得不順暢?',
         'Which steps in the online check-in flow felt unsmooth?',
         '可複選 — 勾選後可選填當時狀況',
         'Multiple selections allowed — optional comment per selection',
         ARRAY['流程體驗','報到'], ARRAY['Flow Experience','Check-in']),

(7,  '1', '累積 / 使用里程流程中,哪些步驟覺得不順暢?',
         'Which steps in the mileage earning/redemption flow felt unsmooth?',
         '可複選 — 勾選後可選填當時狀況',
         'Multiple selections allowed — optional comment per selection',
         ARRAY['流程體驗','里程'], ARRAY['Flow Experience','Mileage']),

(8,  '1', '請描述你最近一次用 App 的體驗',
         'Describe your most recent experience using the App',
         '從訂票到落地,遇到了哪些不順暢、卡住的地方?特別寫出最卡 / 最難用的環節(可空白)',
         'From booking to landing, which steps were unsmooth or got stuck? Highlight the most frustrating ones (optional)',
         ARRAY['旅程描述'], ARRAY['Journey Story']),

(9,  '1', '當你在 App 卡關時,App 有沒有給你明確的訊息告訴你發生什麼事?',
         'When you got stuck in the App, did it clearly tell you what happened?',
         '如果沒卡過,選 3 (中間)',
         'If never stuck, choose 3 (neutral)',
         ARRAY['系統訊息'], ARRAY['System Messaging']),

(10, '1', '整體來說,你給 STARLUX App 使用體驗的評分?',
         'Overall, how would you rate the STARLUX App experience?',
         NULL, NULL,
         ARRAY['整體評分'], ARRAY['Overall Rating']),

(11, '1', '還有想跟我們分享的嗎?',
         'Anything else you''d like to share with us?',
         '可空白 · 例如最該改進的地方、印象深刻的功能、其他想法',
         'Optional — e.g. things to improve, memorable features, other thoughts',
         ARRAY['開放回饋'], ARRAY['Open Feedback']);

-- ------------------------------------------------------------
-- answer（questionId 透過 sortOrder + version 撈現行版 question.id）
-- Q8 / Q11 為純文字題，無預設答案
-- ------------------------------------------------------------

-- Q1: 篩選
INSERT INTO "answer" ("questionId","sortOrder","labelZh","labelEn") VALUES
((SELECT "id" FROM "question" WHERE "sortOrder"=1 AND "version"='1'), 1, '有用過',  'Yes, I have'),
((SELECT "id" FROM "question" WHERE "sortOrder"=1 AND "version"='1'), 2, '沒用過',  'No, I haven''t');

-- Q2: 使用情境
INSERT INTO "answer" ("questionId","sortOrder","labelZh","labelEn") VALUES
((SELECT "id" FROM "question" WHERE "sortOrder"=2 AND "version"='1'), 1, '商務出差 — 自己訂',                  'Business trip — booked by myself'),
((SELECT "id" FROM "question" WHERE "sortOrder"=2 AND "version"='1'), 2, '商務出差 — 公司 / 旅行社代訂',         'Business trip — booked by company / agency'),
((SELECT "id" FROM "question" WHERE "sortOrder"=2 AND "version"='1'), 3, '個人旅遊 / 探親',                    'Personal travel / visiting family'),
((SELECT "id" FROM "question" WHERE "sortOrder"=2 AND "version"='1'), 4, '其他',                              'Other');

-- Q3: 使用過的流程
INSERT INTO "answer" ("questionId","sortOrder","labelZh","labelEn") VALUES
((SELECT "id" FROM "question" WHERE "sortOrder"=3 AND "version"='1'), 1, '訂票',          'Booking'),
((SELECT "id" FROM "question" WHERE "sortOrder"=3 AND "version"='1'), 2, '改票 / 退票',    'Change / refund'),
((SELECT "id" FROM "question" WHERE "sortOrder"=3 AND "version"='1'), 3, '線上報到',       'Online check-in'),
((SELECT "id" FROM "question" WHERE "sortOrder"=3 AND "version"='1'), 4, '累積 / 使用里程', 'Earn / redeem mileage'),
((SELECT "id" FROM "question" WHERE "sortOrder"=3 AND "version"='1'), 5, '都沒實際做過',    'None of the above');

-- Q4: 訂票流程
INSERT INTO "answer" ("questionId","sortOrder","labelZh","labelEn") VALUES
((SELECT "id" FROM "question" WHERE "sortOrder"=4 AND "version"='1'), 1, '選地點 / 時間',  'Select destination / time'),
((SELECT "id" FROM "question" WHERE "sortOrder"=4 AND "version"='1'), 2, '選艙等',         'Select cabin class'),
((SELECT "id" FROM "question" WHERE "sortOrder"=4 AND "version"='1'), 3, '填個人資料',     'Enter personal info'),
((SELECT "id" FROM "question" WHERE "sortOrder"=4 AND "version"='1'), 4, '選位',          'Select seat'),
((SELECT "id" FROM "question" WHERE "sortOrder"=4 AND "version"='1'), 5, '加購行李',       'Add baggage'),
((SELECT "id" FROM "question" WHERE "sortOrder"=4 AND "version"='1'), 6, '加購餐點',       'Add meal'),
((SELECT "id" FROM "question" WHERE "sortOrder"=4 AND "version"='1'), 7, '付款',          'Payment'),
((SELECT "id" FROM "question" WHERE "sortOrder"=4 AND "version"='1'), 8, '其他',          'Other');

-- Q5: 改票流程
INSERT INTO "answer" ("questionId","sortOrder","labelZh","labelEn") VALUES
((SELECT "id" FROM "question" WHERE "sortOrder"=5 AND "version"='1'), 1, '找到改票入口',     'Find change ticket entry'),
((SELECT "id" FROM "question" WHERE "sortOrder"=5 AND "version"='1'), 2, '修改日期 / 航班',   'Modify date / flight'),
((SELECT "id" FROM "question" WHERE "sortOrder"=5 AND "version"='1'), 3, '補差價計算',       'Fare difference calculation'),
((SELECT "id" FROM "question" WHERE "sortOrder"=5 AND "version"='1'), 4, '確認 / 付款',      'Confirm / payment'),
((SELECT "id" FROM "question" WHERE "sortOrder"=5 AND "version"='1'), 5, '其他',            'Other');

-- Q6: 報到流程
INSERT INTO "answer" ("questionId","sortOrder","labelZh","labelEn") VALUES
((SELECT "id" FROM "question" WHERE "sortOrder"=6 AND "version"='1'), 1, '找到報到入口',                'Find check-in entry'),
((SELECT "id" FROM "question" WHERE "sortOrder"=6 AND "version"='1'), 2, '選位 / 換位',                'Select / change seat'),
((SELECT "id" FROM "question" WHERE "sortOrder"=6 AND "version"='1'), 3, '加購行李',                   'Add baggage'),
((SELECT "id" FROM "question" WHERE "sortOrder"=6 AND "version"='1'), 4, '下載登機證 / 加入 Wallet',     'Download boarding pass / add to Wallet'),
((SELECT "id" FROM "question" WHERE "sortOrder"=6 AND "version"='1'), 5, '其他',                      'Other');

-- Q7: 里程流程
INSERT INTO "answer" ("questionId","sortOrder","labelZh","labelEn") VALUES
((SELECT "id" FROM "question" WHERE "sortOrder"=7 AND "version"='1'), 1, '累積里程查詢',  'Check accumulated mileage'),
((SELECT "id" FROM "question" WHERE "sortOrder"=7 AND "version"='1'), 2, '折抵機票',      'Redeem for tickets'),
((SELECT "id" FROM "question" WHERE "sortOrder"=7 AND "version"='1'), 3, '兌換獎勵',      'Redeem rewards'),
((SELECT "id" FROM "question" WHERE "sortOrder"=7 AND "version"='1'), 4, '帳戶資訊顯示',  'Account info display'),
((SELECT "id" FROM "question" WHERE "sortOrder"=7 AND "version"='1'), 5, '其他',         'Other');

-- Q9: 5 點量表（系統訊息明確度）
INSERT INTO "answer" ("questionId","sortOrder","labelZh","labelEn") VALUES
((SELECT "id" FROM "question" WHERE "sortOrder"=9 AND "version"='1'), 1, '1 — 完全沒訊息',      '1 — No information at all'),
((SELECT "id" FROM "question" WHERE "sortOrder"=9 AND "version"='1'), 2, '2',                  '2'),
((SELECT "id" FROM "question" WHERE "sortOrder"=9 AND "version"='1'), 3, '3 — 中間',           '3 — Neutral'),
((SELECT "id" FROM "question" WHERE "sortOrder"=9 AND "version"='1'), 4, '4',                  '4'),
((SELECT "id" FROM "question" WHERE "sortOrder"=9 AND "version"='1'), 5, '5 — 訊息非常明確',     '5 — Very clear');

-- Q10: 5 點量表（整體評分）
INSERT INTO "answer" ("questionId","sortOrder","labelZh","labelEn") VALUES
((SELECT "id" FROM "question" WHERE "sortOrder"=10 AND "version"='1'), 1, '1 — 非常不好',       '1 — Very bad'),
((SELECT "id" FROM "question" WHERE "sortOrder"=10 AND "version"='1'), 2, '2',                  '2'),
((SELECT "id" FROM "question" WHERE "sortOrder"=10 AND "version"='1'), 3, '3 — 普通',           '3 — Average'),
((SELECT "id" FROM "question" WHERE "sortOrder"=10 AND "version"='1'), 4, '4',                  '4'),
((SELECT "id" FROM "question" WHERE "sortOrder"=10 AND "version"='1'), 5, '5 — 非常好',         '5 — Very good');
