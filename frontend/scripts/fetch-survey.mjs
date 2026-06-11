// build-time：從後端抓問卷定義，freeze 進 src/data/survey.json（之後 inline 進 bundle）
// 失敗時退回 src/data/survey.fallback.json（最後一次成功的版本）
import fs from 'node:fs/promises'

const API = process.env.API_URL || 'http://localhost:8080'
const OUT = 'src/data/survey.json'
const FALLBACK = 'src/data/survey.fallback.json'

await fs.mkdir('src/data', { recursive: true })

try {
    const res = await fetch(`${API}/api/survey`)
    if (!res.ok) throw new Error(`HTTP ${res.status}`)
    const data = await res.json()
    if (!data?.questions?.length) throw new Error('回傳沒有 questions')
    await fs.writeFile(OUT, JSON.stringify(data, null, 2) + '\n')
    console.log(`✓ survey.json 已更新（${data.questions.length} 題，來源 ${API}）`)
} catch (e) {
    console.warn(`✗ 抓取失敗（${e.message}），改用 fallback`)
    await fs.copyFile(FALLBACK, OUT)
}
