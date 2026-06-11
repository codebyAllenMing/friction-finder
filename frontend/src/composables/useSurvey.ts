import surveyData from '@/data/survey.json'
import type { Answer, Locale, Question, Survey } from '@/types/survey'

// build-time inline 進 bundle 的問卷定義（來源：後端 get_survey）
const survey = surveyData as Survey
const questions = [...survey.questions].sort((a, b) => a.sortOrder - b.sortOrder)

export function useSurvey() {
    function getQuestion(sortOrder: number): Question | undefined {
        return questions.find((q) => q.sortOrder === sortOrder)
    }

    // stepId 'q4' → sortOrder 4
    function getQuestionByStep(stepId: string): Question | undefined {
        const order = Number(stepId.replace(/^q/, ''))
        return Number.isNaN(order) ? undefined : getQuestion(order)
    }

    function questionLabel(q: Question, locale: Locale): string {
        return locale === 'en' ? q.labelEn : q.labelZh
    }

    function questionHint(q: Question, locale: Locale): string | null {
        return locale === 'en' ? q.hintEn : q.hintZh
    }

    function answerLabel(a: Answer, locale: Locale): string {
        return locale === 'en' ? a.labelEn : a.labelZh
    }

    return {
        questions,
        getQuestion,
        getQuestionByStep,
        questionLabel,
        questionHint,
        answerLabel,
    }
}
