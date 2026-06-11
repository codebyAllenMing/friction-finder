import { createRouter, createWebHistory } from 'vue-router'
import IntroView from '@/views/IntroView.vue'
import SurveyView from '@/views/SurveyView.vue'
import EndView from '@/views/EndView.vue'
import NotFoundView from '@/views/NotFoundView.vue'

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        { path: '/', name: 'intro', component: IntroView },
        { path: '/survey/:step', name: 'survey', component: SurveyView },
        { path: '/end/:kind', name: 'end', component: EndView },
        { path: '/404', name: 'notFound', component: NotFoundView },
        // 完全不存在的路徑 → 404（保留原網址）
        { path: '/:pathMatch(.*)*', component: NotFoundView },
    ],
    scrollBehavior() {
        return { top: 0 }
    },
})

export default router
