<script setup lang="ts">
import { computed } from 'vue'
import QuestionHeader from './QuestionHeader.vue'
import { useSurveyStore } from '@/stores/survey'
import type { Question } from '@/types/survey'

// 純文字題（Q8 / Q11）。可空白。placeholder 由父層依題目帶入。
const props = defineProps<{ question: Question; placeholder?: string }>()
const store = useSurveyStore()

const text = computed(() => store.getAnswer(props.question.questionId).responseText)

function setText(val: string) {
    const cur = store.getAnswer(props.question.questionId)
    store.setAnswer(props.question.questionId, { ...cur, responseText: val })
}
</script>

<template>
    <div>
        <QuestionHeader :question="question" />
        <textarea
            :name="`q${question.questionId}-text`"
            :value="text"
            :placeholder="placeholder"
            rows="6"
            autocomplete="off"
            class="w-full resize-y rounded-xl border border-border bg-surface px-4 py-3 text-text placeholder:text-muted focus:border-primary focus:outline-none"
            @input="setText(($event.target as HTMLTextAreaElement).value)"
        />
    </div>
</template>
