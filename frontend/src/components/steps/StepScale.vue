<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import QuestionHeader from './QuestionHeader.vue'
import { useSurveyStore } from '@/stores/survey'
import type { Question } from '@/types/survey'

// 1–5 量表（Q9 / Q10）。選項值是純數字；兩端錨點文字寫死在前端 i18n（scale.{sortOrder}.low/high）。
const props = defineProps<{ question: Question }>()
const store = useSurveyStore()
const { t } = useI18n()

const selectedId = computed(() => store.getAnswer(props.question.questionId).selected[0] ?? null)

function select(answerId: number) {
    store.setAnswer(props.question.questionId, {
        selected: [answerId],
        texts: {},
        responseText: '',
    })
}

const lowLabel = computed(() => t(`scale.${props.question.sortOrder}.low`))
const highLabel = computed(() => t(`scale.${props.question.sortOrder}.high`))
</script>

<template>
    <div>
        <QuestionHeader :question="question" />
        <div class="grid grid-cols-5 gap-3">
            <button
                v-for="a in question.answers"
                :key="a.answerId"
                type="button"
                class="rounded-2xl border py-6 text-lg font-bold transition-colors"
                :class="
                    selectedId === a.answerId
                        ? 'border-primary bg-primary text-white shadow-sm'
                        : 'border-border bg-surface text-text hover:border-primary/40'
                "
                @click="select(a.answerId)"
            >
                {{ a.sortOrder }}
            </button>
        </div>
        <div class="mt-3 flex justify-between text-sm text-muted">
            <span>{{ lowLabel }}</span>
            <span>{{ highLabel }}</span>
        </div>
    </div>
</template>
