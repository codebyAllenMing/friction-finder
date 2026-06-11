import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { i18n } from '@/i18n'
import router from '@/router'
import { useSurveyStore } from '@/stores/survey'
import { initTheme } from '@/lib/theme'
import '@/assets/styles/main.css'
import App from './App.vue'

// 還原暗/亮主題（須在掛載前，避免閃一下亮色）
initTheme()

const app = createApp(App)
app.use(createPinia())
app.use(i18n)

// 還原進行中的作答（7 天內），須在掛載 router 前
useSurveyStore().hydrate()

app.use(router)
app.mount('#app')
