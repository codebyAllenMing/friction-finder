import { useI18n } from 'vue-i18n'
import { http } from '@/lib/http'
import { useSurvey } from '@/composables/useSurvey'
import { useSurveyFlow } from '@/composables/useSurveyFlow'
import { STEP_TYPE } from '@/composables/surveyConfig'
import { useSurveyStore } from '@/stores/survey'
import { useInterviewStore } from '@/stores/interview'
import type { Locale } from '@/types/survey'

// 送出 payload（對齊後端 SubmitRequest）。只送 id，label 由後端用 id 從 question/answer 表查。
// 純文字題 answerId 為 null。
interface SubmitAnswer {
    answerId: number | null
    responseText: string | null
}
interface SubmitItem {
    questionId: number
    answers: SubmitAnswer[]
}

export function useSubmit() {
    const { locale } = useI18n()
    const { getQuestion } = useSurvey()
    const flow = useSurveyFlow()
    const survey = useSurveyStore()
    const interview = useInterviewStore()

    const loc = () => locale.value as Locale

    // 依「這次實際走的題目」組 items；可空白的文字題若沒填則略過
    function buildItems(): SubmitItem[] {
        const items: SubmitItem[] = []
        for (const sort of flow.activeSorts.value) {
            const q = getQuestion(sort)
            if (!q) continue
            const ans = survey.getAnswer(q.questionId)

            let answers: SubmitAnswer[]
            if (STEP_TYPE[sort] === 'text') {
                const txt = ans.responseText.trim()
                if (!txt) continue // 可空白文字題沒填 → 不送這筆
                answers = [{ answerId: null, responseText: txt }]
            } else {
                answers = q.answers
                    .filter((a) => ans.selected.includes(a.answerId))
                    .map((a) => ({
                        answerId: a.answerId,
                        responseText: ans.texts[a.answerId]?.trim() || null,
                    }))
                if (!answers.length) continue
            }
            items.push({ questionId: q.questionId, answers })
        }
        return items
    }

    // 設 true 時只印 payload、不打 API（檢視格式用）；false = 真正送出。
    const DRY_RUN = false

    async function submit(): Promise<boolean> {
        const payload = {
            locale: loc(),
            items: buildItems(),
            interview:
                interview.wantInterview && interview.isValid
                    ? { name: interview.name.trim(), email: interview.email.trim() }
                    : null,
        }

        if (DRY_RUN) {
            console.log('[submit dry-run] payload =', payload)
            console.log('[submit dry-run] JSON =\n' + JSON.stringify(payload, null, 2))
            return false // 不導向完成頁，留在 Q11 方便反覆檢視
        }

        survey.submitState = 'submitting'
        survey.persist() // 送出前確保落盤
        try {
            await http.post('/api/responses', payload)
            survey.submitState = 'success'
            return true
        } catch {
            survey.submitState = 'error'
            return false
        }
    }

    return { submit }
}
