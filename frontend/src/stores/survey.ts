import { defineStore } from 'pinia'
import { computed, ref } from 'vue'

const STORAGE_KEY = 'survey:state:v1'
const EXPIRE_MS = 7 * 86_400_000 // 7 天

export interface AnswerState {
    selected: number[] // 勾選的 answerId（單選 1 個 / 複選多個 / 純文字題為空）
    texts: Record<number, string> // key = answerId，該選項的補述文字（如 Q4「其他」）
    responseText: string // 純文字題（Q8 / Q11）的答案
}

interface PersistedState {
    version: 'v1'
    savedAt: number
    currentStep: string
    history: string[]
    answers: Record<number, AnswerState>
}

function emptyAnswer(): AnswerState {
    return { selected: [], texts: {}, responseText: '' }
}

export const useSurveyStore = defineStore('survey', () => {
    // state
    const answers = ref<Record<number, AnswerState>>({})
    const currentStep = ref('intro')
    const history = ref<string[]>(['intro'])
    const submitState = ref<'idle' | 'submitting' | 'success' | 'error'>('idle')

    // getters
    const isComplete = computed(() => submitState.value === 'success')

    // 答案
    function getAnswer(questionId: number): AnswerState {
        return answers.value[questionId] ?? emptyAnswer()
    }

    function setAnswer(questionId: number, state: AnswerState) {
        answers.value[questionId] = state
        persist()
    }

    // 導覽
    function setCurrentStep(step: string) {
        currentStep.value = step
        if (!history.value.includes(step)) history.value.push(step)
        persist()
    }

    function reset() {
        answers.value = {}
        currentStep.value = 'intro'
        history.value = ['intro']
        submitState.value = 'idle'
        localStorage.removeItem(STORAGE_KEY)
    }

    // 持久化
    function persist() {
        const data: PersistedState = {
            version: 'v1',
            savedAt: Date.now(),
            currentStep: currentStep.value,
            history: history.value,
            answers: answers.value,
        }
        localStorage.setItem(STORAGE_KEY, JSON.stringify(data))
    }

    function hydrate() {
        const raw = localStorage.getItem(STORAGE_KEY)
        if (!raw) return
        try {
            const data = JSON.parse(raw) as PersistedState
            // 版本不符或超過 7 天 → 清掉重來
            if (data.version !== 'v1' || Date.now() - (data.savedAt ?? 0) > EXPIRE_MS) {
                localStorage.removeItem(STORAGE_KEY)
                return
            }
            answers.value = data.answers ?? {}
            currentStep.value = data.currentStep ?? 'intro'
            history.value = data.history ?? ['intro']
        } catch {
            localStorage.removeItem(STORAGE_KEY)
        }
    }

    return {
        answers,
        currentStep,
        history,
        submitState,
        isComplete,
        getAnswer,
        setAnswer,
        setCurrentStep,
        reset,
        hydrate,
    }
})
