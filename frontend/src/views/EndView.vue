<script setup lang="ts">
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import SurveyLayout from '@/components/layout/SurveyLayout.vue'
import { useSurveyStore } from '@/stores/survey'
import { useInterviewStore } from '@/stores/interview'

const route = useRoute()
const router = useRouter()
const { t } = useI18n()
const survey = useSurveyStore()
const interview = useInterviewStore()

// kind: 'done' = 正常完成；'screen' = Q1 沒用過被篩除
const isScreen = computed(() => route.params.kind === 'screen')

// 回問卷：清空作答，從頭開始
function backToSurvey() {
    survey.reset()
    interview.reset()
    router.push('/')
}

const title = computed(() => (isScreen.value ? t('end.screenTitle') : t('end.doneTitle')))
const line1 = computed(() => (isScreen.value ? t('end.screenLine1') : t('end.doneLine1')))
const line2 = computed(() => (isScreen.value ? t('end.screenLine2') : t('end.doneLine2')))
</script>

<template>
    <SurveyLayout :right-label="t('common.done')">
        <div class="text-center">
            <h1 class="text-3xl font-bold text-text">🙏 {{ title }}</h1>
            <p class="mt-6 text-muted">{{ line1 }}</p>
            <p class="mt-3 text-muted">{{ line2 }}</p>

            <button
                class="mt-8 rounded-lg bg-primary px-6 py-3 text-sm font-semibold text-white transition-colors hover:bg-primaryhover"
                @click="backToSurvey"
            >
                {{ t('end.backToSurvey') }}
            </button>

            <p class="mx-auto mt-12 max-w-xl text-xs leading-relaxed text-muted/70">
                {{ t('end.disclaimer') }}
            </p>
        </div>
    </SurveyLayout>
</template>
