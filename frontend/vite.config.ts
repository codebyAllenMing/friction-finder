import fs from 'node:fs'
import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import tailwindcss from '@tailwindcss/vite'

// 本機 HTTPS：有 mkcert 憑證才啟用（缺檔則退回 HTTP，不擋 CI / 他人）
const certFile = fileURLToPath(new URL('./certs/localhost.pem', import.meta.url))
const keyFile = fileURLToPath(new URL('./certs/localhost-key.pem', import.meta.url))
const https =
    fs.existsSync(certFile) && fs.existsSync(keyFile)
        ? { cert: fs.readFileSync(certFile), key: fs.readFileSync(keyFile) }
        : undefined

// https://vite.dev/config/
export default defineConfig({
    plugins: [vue(), tailwindcss()],
    resolve: {
        alias: {
            '@': fileURLToPath(new URL('./src', import.meta.url)),
        },
    },
    server: {
        host: true, // 監聽 0.0.0.0 → 手機可用區網 IP 連
        port: 5173,
        strictPort: true, // 5173 被占就直接報錯，不偷偷漂到 5174（避免 Origin 對不上後端白名單）
        https,
        proxy: {
            // 前端打相對 /api（HTTPS、同源）→ Vite 內部轉給 HTTP 後端，避免 mixed content
            '/api': {
                target: 'http://localhost:8080',
                changeOrigin: true,
            },
        },
    },
})
