# Friction Finder

> 一份「STARLUX App 使用體驗」問卷的全端實作 — 從 UI/UX redesign 練習延伸成可實際收資料、可部署的線上問卷。
> 前端 Vue 3 單頁問卷(動態分支),後端 Spring Boot SP-driven API,Postgres + Flyway,CI/CD 到雲端。

<sub>本專案為個人 UI/UX 研究與工程練習(Redesign Project),所用商標 / 企業名稱皆歸原官方所有,僅作學術與作品交流,無商業目的。</sub>

---

## 🖼 畫面

<table>
  <tr>
    <td width="50%"><img src="docs/screenshots/intro.jpg" alt="開場" /></td>
    <td width="50%"><img src="docs/screenshots/screener.jpg" alt="篩選題（單選）" /></td>
  </tr>
  <tr>
    <td><img src="docs/screenshots/multi-comment.jpg" alt="複選 + 逐項補述" /></td>
    <td><img src="docs/screenshots/scale.jpg" alt="1–5 量表" /></td>
  </tr>
</table>

## ✨ 功能

- **動態分支問卷**:篩選題擋掉非目標受訪者;依「用過哪些流程」動態插入對應細節題;進度與題數即時反映分支。
- **多種題型**:單選 / 複選 / 複選+逐項補述 / 1–5 量表 / 開放文字 / 訪談 opt-in(PII 隔離)。
- **雙語 + 主題**:中 / 英即時切換、深淺色,皆持久化。
- **離線可填**:題目於 build 時 inline 進 bundle,開頁不需等 API;送出才打後端。
- **防護**:送出去抖動鎖、無效路由 / 越級守衛、自訂 404、後端 rate limit + origin allowlist。

## 🏗 架構

```
使用者 ──HTTPS──> Cloudflare Pages(前端靜態)
                      │  /api  (TLS 在邊緣終結)
                      ▼
              Azure Container Apps(Spring Boot, HTTP)
                      │  經 Tailscale 私網
                      ▼
              自架 PostgreSQL(不對外網開放)
```

TLS 在邊緣終結 → app 本身只跑 HTTP;前端走相對 `/api`(dev 用 Vite proxy、prod 指向後端 HTTPS),避免 mixed content。資料庫只在私有網路內,不暴露公網。

## 🛠 技術棧

| 層 | 技術 |
|---|---|
| 前端 | Vue 3 (Composition API)・Vite・TypeScript・Tailwind CSS v4・Pinia・Vue Router・vue-i18n・axios |
| 後端 | Java 21・Spring Boot・JdbcTemplate(SP-driven,no ORM)・bucket4j・springdoc OpenAPI |
| 資料 | PostgreSQL・Flyway(版本化 migration)・plpgsql stored functions |
| 測試 / CI | Testcontainers・GitHub Actions → GHCR → Azure Container Apps |

## 🔑 工程亮點

- **SP-driven API**:讀寫都呼叫 Postgres function,不用 ORM。送出時由 `submit_survey()` 用 `questionId`/`answerId` **從定義表查 label 寫入快照**,前端 payload 只送 id(精簡、且文字以 DB 為準不可被竄改)。
- **Build-time 題目 inline**:`prebuild` 從後端抓問卷 freeze 成 JSON 打進 bundle;抓不到自動退回 fallback,開頁零 API 依賴。
- **動態流程引擎**:純前端 composable 依作答計算「這次該走的題序、進度、上一/下一步、分支與篩除」。
- **版本化題庫**:題目以 Flyway migration 演進(只新增不原地改),歷史回應指向當時版本,不受後續改動影響。
- **量表資料乾淨化**:選項值只存數字(1–5),兩端錨點文字放前端 — 概念上就是「星等評分」。
- **邊緣 TLS 架構**:app 純 HTTP、TLS 在 Cloudflare / 容器入口終結,降低憑證與 mixed-content 複雜度。
- **防濫用**:bucket4j per-IP rate limit、Origin allowlist filter、正式環境關閉 Swagger。

## 🚀 本機開發

**後端**(需 Docker + JDK 21)
```bash
cd backend
cp .env.example .env           # 填本機 DB 值
docker compose up -d           # 起 PostgreSQL
./mvnw spring-boot:run         # 啟動 API（Flyway 自動建 schema + seed）
```

**前端**(需 Node 20+)
```bash
cd frontend
cp .env.example .env
npm install
npm run dev                    # https://localhost:5173（本機 HTTPS 走 mkcert）
```

## 📦 部署

- **前端**:Cloudflare Pages(靜態),`public/_redirects` 提供 SPA fallback 讓深連結不 404。
- **後端**:GitHub Actions 建 multi-stage image → 推 GHCR → 更新 Azure Container Apps;DB 經 Tailscale 私網連線。
- 設定全用環境變數覆蓋(`${VAR:default}`),dev/prod 不改程式碼。
