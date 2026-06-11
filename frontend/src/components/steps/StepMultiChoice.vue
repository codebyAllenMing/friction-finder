<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import ChoiceCard from '@/components/ui/ChoiceCard.vue'
import QuestionHeader from './QuestionHeader.vue'
import { useSurveyStore } from '@/stores/survey'
import type { Answer, Question, Locale } from '@/types/survey'

// 複選題（Q3）。exclusiveSort：某個「選了就清掉其他」的互斥選項（如 Q3「都沒實際做過」=5）。
const props = defineProps<{ question: Question; exclusiveSort?: number }>()
const store = useSurveyStore()
const { locale } = useI18n()

const selected = computed(() => store.getAnswer(props.question.questionId).selected)
const exclusiveId = computed(
    () => props.question.answers.find((a) => a.sortOrder === props.exclusiveSort)?.answerId ?? null,
)

function isSel(id: number) {
    return selected.value.includes(id)
}

// 互斥反灰：選了一般流程 → 鎖住互斥項；選了互斥項 → 鎖住一般流程
const hasExclusive = computed(() => exclusiveId.value != null && isSel(exclusiveId.value))
const hasNormal = computed(() =>
    selected.value.some((id) => id !== exclusiveId.value),
)
function isDisabled(a: Answer) {
    if (props.exclusiveSort == null) return false
    return a.answerId === exclusiveId.value ? hasNormal.value : hasExclusive.value
}

function toggle(a: Answer) {
    const cur = selected.value
    let next: number[]
    if (a.answerId === exclusiveId.value) {
        // 互斥項：開 → 只剩它；關 → 清空
        next = isSel(a.answerId) ? [] : [a.answerId]
    } else {
        // 一般項：先把互斥項拿掉,再 toggle 自己
        const base = exclusiveId.value != null ? cur.filter((id) => id !== exclusiveId.value) : cur
        next = isSel(a.answerId) ? base.filter((id) => id !== a.answerId) : [...base, a.answerId]
    }
    store.setAnswer(props.question.questionId, { selected: next, texts: {}, responseText: '' })
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
                control="check"
                :label="label(a)"
                :selected="isSel(a.answerId)"
                :disabled="isDisabled(a)"
                @toggle="toggle(a)"
            />
        </div>
    </div>
</template>
