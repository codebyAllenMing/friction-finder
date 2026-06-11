import { computed } from 'vue'
import { useSurveyStore } from '@/stores/survey'
import { useSurvey } from '@/composables/useSurvey'
import {
    BASE_HEAD,
    BASE_TAIL,
    Q1_SCREEN_OUT_OPTION,
    Q3_NONE_OPTION,
    Q3_OPTION_TO_DETAIL,
} from '@/composables/surveyConfig'

// 動態流程引擎：依目前作答算出「這次要走的題目順序」、進度、上一步/下一步。
// step id 與 sortOrder 互換：sortOrder n ↔ 'q{n}'。
export function stepIdToSort(stepId: string): number | null {
    const n = Number(stepId.replace(/^q/, ''))
    return Number.isNaN(n) ? null : n
}
export function sortToStepId(sort: number): string {
    return `q${sort}`
}

export function useSurveyFlow() {
    const store = useSurveyStore()
    const { getQuestion } = useSurvey()

    // 取某題目前勾選到的「選項 sortOrder」清單
    function selectedOptionSorts(questionSort: number): number[] {
        const q = getQuestion(questionSort)
        if (!q) return []
        const selectedIds = store.getAnswer(q.questionId).selected
        return q.answers.filter((a) => selectedIds.includes(a.answerId)).map((a) => a.sortOrder)
    }

    // Q1 選了「沒用過」→ 篩除
    const screenedOut = computed(() => selectedOptionSorts(1).includes(Q1_SCREEN_OUT_OPTION))

    // Q3 選了「都沒實際做過」→ 不展開細節題
    const noneFlow = computed(() => selectedOptionSorts(3).includes(Q3_NONE_OPTION))

    // 依 Q3 勾選展開的細節題（Q4-7），照 sortOrder 排序
    const detailSorts = computed<number[]>(() => {
        if (noneFlow.value) return []
        return selectedOptionSorts(3)
            .map((opt) => Q3_OPTION_TO_DETAIL[opt])
            .filter((s): s is number => s != null)
            .sort((a, b) => a - b)
    })

    // 這次實際要走的題目（sortOrder 陣列）。被篩除時只剩 Q1。
    const activeSorts = computed<number[]>(() => {
        if (screenedOut.value) return [...BASE_HEAD.slice(0, 1)] // [1]
        return [...BASE_HEAD, ...detailSorts.value, ...BASE_TAIL]
    })

    // 進度分母
    const total = computed(() => activeSorts.value.length)

    function indexOfSort(sort: number): number {
        return activeSorts.value.indexOf(sort)
    }

    // 目前是第幾題（1-based），找不到回 0
    function currentNumber(sort: number): number {
        const i = indexOfSort(sort)
        return i < 0 ? 0 : i + 1
    }

    // 下一步的路由 path。Q1 篩除 → 結尾；Q11 → 送出後的完成頁由 SurveyView 處理（這裡回 'done'）。
    function nextPath(sort: number): string {
        if (sort === 1 && screenedOut.value) return '/end/screen'
        const list = activeSorts.value
        const i = list.indexOf(sort)
        if (i < 0) return '/'
        if (i === list.length - 1) return '/end/done' // 最後一題（Q11 送出後）
        return `/survey/${sortToStepId(list[i + 1])}`
    }

    // 上一步：第一題回 intro,否則回前一個 active 題
    function prevPath(sort: number): string {
        const list = activeSorts.value
        const i = list.indexOf(sort)
        if (i <= 0) return '/'
        return `/survey/${sortToStepId(list[i - 1])}`
    }

    return {
        screenedOut,
        noneFlow,
        detailSorts,
        activeSorts,
        total,
        indexOfSort,
        currentNumber,
        nextPath,
        prevPath,
        selectedOptionSorts,
    }
}
