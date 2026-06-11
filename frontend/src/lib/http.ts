import axios from 'axios'

// 共用 axios 實例。所有 runtime API 呼叫都走這個。
// baseURL = VITE_API_BASE：
//   本機留空 → 相對路徑 /api/...，走 Vite proxy（HTTPS 前端 → HTTP 後端，無 mixed content）
//   正式環境 → 設成後端網址，例如 https://api.你的網域
export const http = axios.create({
    baseURL: import.meta.env.VITE_API_BASE,
    headers: { 'Content-Type': 'application/json' },
    timeout: 15000,
})
