import { createI18n } from 'vue-i18n'
import type { Locale } from '@/types/survey'
import zh from './locales/zh.json'
import en from './locales/en.json'

const STORAGE_KEY = 'survey:locale'
export const SUPPORTED_LOCALES: Locale[] = ['zh', 'en']

/** 偵測初始語言：localStorage > 瀏覽器語言 > 預設 zh。實際以路由 URL 為準（router 會覆蓋）。 */
export function detectLocale(): Locale {
    const saved = localStorage.getItem(STORAGE_KEY)
    if (saved === 'zh' || saved === 'en') return saved
    return navigator.language.toLowerCase().startsWith('en') ? 'en' : 'zh'
}

export const i18n = createI18n({
    legacy: false, // Composition API 模式
    locale: detectLocale(),
    fallbackLocale: 'zh',
    messages: { zh, en },
})

/** 切換語言：同步 i18n、localStorage、<html lang>。 */
export function setLocale(locale: Locale) {
    i18n.global.locale.value = locale
    localStorage.setItem(STORAGE_KEY, locale)
    document.documentElement.lang = locale === 'en' ? 'en' : 'zh-Hant'
}
