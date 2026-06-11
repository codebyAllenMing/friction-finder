<script setup lang="ts">
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import SurveyLayout from '@/components/layout/SurveyLayout.vue'
import { useSurveyStore } from '@/stores/survey'

const router = useRouter()
const { t } = useI18n()
const store = useSurveyStore()

function start() {
    store.setCurrentStep('q1')
    router.push('/survey/q1')
}
</script>

<template>
    <SurveyLayout>
        <h1 class="text-3xl font-bold leading-snug text-text">{{ t('intro.title') }}</h1>
        <p class="mt-3 text-muted">{{ t('intro.duration') }}</p>

        <hr class="my-6 border-border" />

        <p class="text-lg text-text">{{ t('intro.lead') }}</p>
        <ul class="mt-4 space-y-2 text-muted">
            <li class="flex gap-2"><span>•</span>{{ t('intro.bulletAnon') }}</li>
            <li class="flex gap-2"><span>•</span>{{ t('intro.bulletHonest') }}</li>
            <li class="flex gap-2"><span>•</span>{{ t('intro.bulletNoSave') }}</li>
        </ul>

        <div class="mt-10 flex justify-end">
            <button
                class="rounded-lg bg-primary px-6 py-3 text-sm font-semibold text-white transition-colors hover:bg-primaryhover"
                @click="start"
            >
                {{ t('intro.start') }} →
            </button>
        </div>
    </SurveyLayout>
</template>
