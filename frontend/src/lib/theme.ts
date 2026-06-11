// 暗/亮主題：記在 localStorage，重整後沿用；首訪沒存過則跟隨系統偏好。
// 切換機制跟 i18n 一樣是「狀態驅動」——這裡的狀態就是 <html> 上的 .dark class。
const STORAGE_KEY = 'survey:theme'

/** 還原主題：localStorage 優先，否則跟系統。需在 app 掛載前呼叫（避免閃一下）。 */
export function initTheme() {
    const saved = localStorage.getItem(STORAGE_KEY)
    const dark =
        saved === 'dark' || saved === 'light'
            ? saved === 'dark'
            : !!window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches
    document.documentElement.classList.toggle('dark', dark)
}

/** 設定並記住主題。 */
export function setDark(dark: boolean) {
    document.documentElement.classList.toggle('dark', dark)
    localStorage.setItem(STORAGE_KEY, dark ? 'dark' : 'light')
}
