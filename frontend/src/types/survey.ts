export type Locale = 'zh' | 'en'

export interface Answer {
    answerId: number
    sortOrder: number
    labelZh: string
    labelEn: string
}

export interface Question {
    questionId: number
    sortOrder: number
    version: string
    labelZh: string
    labelEn: string
    hintZh: string | null
    hintEn: string | null
    tagZh: string[]
    tagEn: string[]
    answers: Answer[]
}

export interface Survey {
    questions: Question[]
}
