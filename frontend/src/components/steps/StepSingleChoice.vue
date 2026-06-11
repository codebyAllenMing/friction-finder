<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import ChoiceCard from '@/components/ui/ChoiceCard.vue'
import QuestionHeader from './QuestionHeader.vue'
import { useSurveyStore } from '@/stores/survey'
import type { Answer, Question, Locale } from '@/types/survey'

// 單選題（Q1 / Q2）。badges：以「選項 sortOrder」為 key 的右側分支標籤（如 Q1 沒用過 → 結尾）。
const props = defineProps<{ question: Question; badges?: Record<number, string> }>()
const store = useSurveyStore()
const { locale } = useI18n()

const selectedId = computed(() => store.getAnswer(props.question.questionId).selected[0] ?? null)

function select(answerId: number) {
    store.setAnswer(props.question.questionId, {
        selected: [answerId],
        texts: {},
        responseText: '',
    })
}

function label(a: Answer) {
    return (locale.value as Locale) === 'en' ? a.labelEn : a.labelZh
}
</script>

<template>
    <div>
        <QuestionHeader :question="question" />
        <div class="space-y-3">
            <ChoiceCard
                v-for="a in question.answers"
                :key="a.answerId"
                control="radio"
                :label="label(a)"
                :selected="selectedId === a.answerId"
                :dashed="!!badges?.[a.sortOrder]"
                :badge="badges?.[a.sortOrder] ?? ''"
                @toggle="select(a.answerId)"
            />
        </div>
    </div>
</template>
