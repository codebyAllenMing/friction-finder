<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import type { Question, Locale } from '@/types/survey'

const props = defineProps<{ question: Question }>()
const { locale } = useI18n()

const loc = computed(() => locale.value as Locale)
const tag = computed(() => {
    const tags = loc.value === 'en' ? props.question.tagEn : props.question.tagZh
    return tags?.[0] ?? ''
})
const label = computed(() =>
    loc.value === 'en' ? props.question.labelEn : props.question.labelZh,
)
const hint = computed(() => (loc.value === 'en' ? props.question.hintEn : props.question.hintZh))
</script>

<template>
    <div class="mb-6">
        <p class="mb-2 text-sm font-bold tracking-wide text-primary">
            Q{{ question.sortOrder }} <span class="text-primary/60">/ {{ tag }}</span>
        </p>
        <h2 class="text-2xl font-bold leading-snug text-text">{{ label }}</h2>
        <p v-if="hint" class="mt-2 text-muted">{{ hint }}</p>
    </div>
</template>
