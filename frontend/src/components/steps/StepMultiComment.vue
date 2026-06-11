<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import QuestionHeader from './QuestionHeader.vue'
import { useSurveyStore } from '@/stores/survey'
import type { Answer, Question, Locale } from '@/types/survey'

// 複選 + 每項勾選後可選填「當時狀況」（Q4–Q7）。補述框收在「同一張卡片」內。
const props = defineProps<{ question: Question }>()
const store = useSurveyStore()
const { locale, t } = useI18n()

const state = computed(() => store.getAnswer(props.question.questionId))

function isSel(id: number) {
    return state.value.selected.includes(id)
}

function toggle(a: Answer) {
    const cur = store.getAnswer(props.question.questionId)
    const selected = isSel(a.answerId)
        ? cur.selected.filter((id) => id !== a.answerId)
        : [...cur.selected, a.answerId]
    const texts = { ...cur.texts }
    if (!selected.includes(a.answerId)) delete texts[a.answerId] // 取消勾選 → 連同補述清掉
    store.setAnswer(props.question.questionId, { ...cur, selected, texts })
}

function textOf(id: number) {
    return state.value.texts[id] ?? ''
}

function setText(id: number, val: string) {
    const cur = store.getAnswer(props.question.questionId)
    store.setAnswer(props.question.questionId, { ...cur, texts: { ...cur.texts, [id]: val } })
}

function label(a: Answer) {
    return (locale.value as Locale) === 'en' ? a.labelEn : a.labelZh
}
</script>

<template>
    <div>
        <QuestionHeader :question="question" />
        <div class="space-y-3">
            <div
                v-for="a in question.answers"
                :key="a.answerId"
                class="overflow-hidden rounded-2xl border transition-colors"
                :class="
                    isSel(a.answerId)
                        ? 'border-primary bg-primarysoft shadow-sm ring-1 ring-primary'
                        : 'border-border bg-surface'
                "
            >
                <!-- 標頭：勾選列（整列可點） -->
                <button
                    type="button"
                    class="flex w-full items-center gap-3 px-5 py-4 text-left"
                    @click="toggle(a)"
                >
                    <span
                        class="flex size-5 shrink-0 items-center justify-center rounded border-2 text-white"
                        :class="
                            isSel(a.answerId)
                                ? 'border-primary bg-primary'
                                : 'border-muted bg-transparent'
                        "
                    >
                        <span v-if="isSel(a.answerId)" class="text-xs leading-none">✓</span>
                    </span>
                    <span class="flex-1 text-text" :class="isSel(a.answerId) ? 'font-medium' : ''">
                        {{ label(a) }}
                    </span>
                </button>

                <!-- 補述：同一張卡片內滑出（grid 0fr→1fr，補間到內容真實高度） -->
                <Transition name="expand">
                    <div v-if="isSel(a.answerId)" class="expand-grid">
                        <div class="expand-inner">
                            <div class="px-5 pb-4">
                                <input
                                    :name="`q${question.questionId}-comment-${a.answerId}`"
                                    :value="textOf(a.answerId)"
                                    :placeholder="t('field.commentPlaceholder')"
                                    autocomplete="off"
                                    class="w-full rounded-xl border border-primary/30 bg-bg px-4 py-2.5 text-sm text-text placeholder:text-muted focus:border-primary focus:outline-none"
                                    @input="setText(a.answerId, ($event.target as HTMLInputElement).value)"
                                />
                            </div>
                        </div>
                    </div>
                </Transition>
            </div>
        </div>
    </div>
</template>

<style scoped>
/* 勾選後補述框在同一張卡片內滑出：grid-template-rows 0fr→1fr 補間到內容真實高度，
   全時間軸都在動、無死時間，比 max-height 平順。 */
.expand-grid {
    display: grid;
}
.expand-inner {
    overflow: hidden;
    min-height: 0;
}
.expand-enter-active,
.expand-leave-active {
    transition:
        grid-template-rows 0.24s ease,
        opacity 0.24s ease;
}
.expand-enter-from,
.expand-leave-to {
    grid-template-rows: 0fr;
    opacity: 0;
}
.expand-enter-to,
.expand-leave-from {
    grid-template-rows: 1fr;
    opacity: 1;
}
</style>
