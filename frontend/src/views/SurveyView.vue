<script setup lang="ts">
import { computed, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import SurveyLayout from '@/components/layout/SurveyLayout.vue'
import StepNav from '@/components/layout/StepNav.vue'
import StepSingleChoice from '@/components/steps/StepSingleChoice.vue'
import StepMultiChoice from '@/components/steps/StepMultiChoice.vue'
import StepMultiComment from '@/components/steps/StepMultiComment.vue'
import StepScale from '@/components/steps/StepScale.vue'
import StepText from '@/components/steps/StepText.vue'
import InterviewOptIn from '@/components/steps/InterviewOptIn.vue'
import QuestionHeader from '@/components/steps/QuestionHeader.vue'
import { useSurvey } from '@/composables/useSurvey'
import { useSurveyStore } from '@/stores/survey'
import { useInterviewStore } from '@/stores/interview'
import { useSurveyFlow, stepIdToSort } from '@/composables/useSurveyFlow'
import { useSubmit } from '@/composables/useSubmit'
import { STEP_TYPE, Q3_NONE_OPTION } from '@/composables/surveyConfig'

const route = useRoute()
const router = useRouter()
const { t } = useI18n()
const { getQuestion } = useSurvey()
const store = useSurveyStore()
const interview = useInterviewStore()
const flow = useSurveyFlow()
const { submit } = useSubmit()

const sort = computed(() => stepIdToSort(String(route.params.step)) ?? 0)
const question = computed(() => getQuestion(sort.value))
const type = computed(() => STEP_TYPE[sort.value])

// 守衛（防直接深連結 / 空 store 亂切）：
//  1) Q1（篩選入口）還沒答 → 不准停在 Q1 以後的題
//  2) 落在「這次流程不該出現」的題（分支沒選卻深連結）→ 拉回 intro
watch(
    () => [sort.value, flow.activeSorts.value] as const,
    () => {
        // 無效的 step（如 /survey/sadasd、/survey/q99）→ 題目不存在 → 導到 404
        if (!question.value) {
            router.replace('/404')
            return
        }
        const q1 = getQuestion(1)
        const q1Answered = q1 ? store.getAnswer(q1.questionId).selected.length > 0 : false
        if (!q1Answered && sort.value !== 1) {
            router.replace('/')
            return
        }
        if (!flow.activeSorts.value.includes(sort.value)) {
            router.replace('/')
        }
    },
    { immediate: true },
)

watch(
    sort,
    (s) => {
        if (s) store.setCurrentStep(`q${s}`)
    },
    { immediate: true },
)

// 分支標籤（目前不顯示；分支邏輯仍在 useSurveyFlow 運作）
const badges = computed<Record<number, string>>(() => ({}))

// 文字題的 placeholder：Q8 旅程故事 / Q11 開放回饋
const textPlaceholder = computed(() =>
    sort.value === 11 ? t('field.feedbackPlaceholder') : t('field.storyPlaceholder'),
)

// 最後一題
const isLastStep = computed(
    () => flow.indexOfSort(sort.value) === flow.activeSorts.value.length - 1,
)
// 真正會「送出」的步驟：最後一題、且不是 Q1「沒用過」被篩除。
// 篩除時這次流程只剩 [Q1]，雖也是「最後一題」，但要去 /end/screen 而非送出。
const submitStep = computed(() => isLastStep.value && !flow.screenedOut.value)
const busy = computed(() => store.submitState === 'submitting')
const nextLabel = computed(() => {
    if (busy.value) return t('common.submitting')
    return submitStep.value ? t('common.submit') : t('common.next')
})

// 是否可以前進（必答題的驗證）
const canProceed = computed(() => {
    const q = question.value
    if (!q) return false
    const ans = store.getAnswer(q.questionId)
    let ok: boolean
    switch (type.value) {
        case 'single':
        case 'scale':
            ok = ans.selected.length === 1
            break
        case 'multi':
        case 'multiComment':
            ok = ans.selected.length >= 1
            break
        // text 可空白
        default:
            ok = true
    }
    // 送出步驟：若勾了訪談，稱呼/Email 須填齊
    if (submitStep.value && !interview.isValid) ok = false
    return ok
})

async function goNext() {
    if (!canProceed.value || busy.value) return
    if (submitStep.value) {
        const ok = await submit()
        if (ok) {
            await router.push('/end/done')
            store.reset()
            interview.reset()
        }
        return
    }
    // 非送出步驟：交給 flow.nextPath（Q1「沒用過」→ /end/screen；其餘 → 下一題）
    router.push(flow.nextPath(sort.value))
}
function goBack() {
    router.push(flow.prevPath(sort.value))
}
</script>

<template>
    <SurveyLayout
        :show-progress="true"
        :current="flow.currentNumber(sort)"
        :total="flow.total.value"
    >
        <template v-if="question">
            <StepSingleChoice
                v-if="type === 'single'"
                :question="question"
                :badges="badges"
            />

            <StepMultiChoice
                v-else-if="type === 'multi'"
                :question="question"
                :exclusive-sort="Q3_NONE_OPTION"
            />

            <StepMultiComment v-else-if="type === 'multiComment'" :question="question" />

            <StepScale v-else-if="type === 'scale'" :question="question" />

            <StepText
                v-else-if="type === 'text'"
                :question="question"
                :placeholder="textPlaceholder"
            />

            <!-- 其餘題型（理論上不會走到） -->
            <div v-else>
                <QuestionHeader :question="question" />
                <div
                    class="rounded-xl border border-dashed border-border bg-surface px-5 py-10 text-center text-muted"
                >
                    🚧 此題型（{{ type }}）下一步實作
                </div>
            </div>

            <!-- Q11 底部：訪談 opt-in -->
            <InterviewOptIn v-if="sort === 11" class="mt-6" />

            <p v-if="store.submitState === 'error'" class="mt-4 text-sm text-danger">
                {{ t('error.submitFailed') }}
            </p>

            <StepNav
                :next-label="nextLabel"
                :next-disabled="!canProceed || busy"
                @back="goBack"
                @next="goNext"
            />
        </template>
    </SurveyLayout>
</template>
