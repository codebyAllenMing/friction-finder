// 題型與分支規則：資料（後端 get_survey）只給題目/選項文字，不含「這題是什麼型」與「怎麼分支」，
// 那是前端 UX 邏輯，集中寫在這裡。以 sortOrder 對應（穩定、不依賴 DB 的 answerId）。

export type StepType =
    | 'single' // 單選（Q1 / Q2）
    | 'multi' // 複選（Q3）
    | 'multiComment' // 複選 + 每項可選填狀況（Q4–Q7）
    | 'text' // 純文字（Q8 / Q11）
    | 'scale' // 1–5 量表（Q9 / Q10）

// 每題 sortOrder → 題型
export const STEP_TYPE: Record<number, StepType> = {
    1: 'single',
    2: 'single',
    3: 'multi',
    4: 'multiComment',
    5: 'multiComment',
    6: 'multiComment',
    7: 'multiComment',
    8: 'text',
    9: 'scale',
    10: 'scale',
    11: 'text',
}

// 題目分組：永遠會出現的「主幹」題（Q1-3 + Q8-11）；Q4-7 是依 Q3 勾選動態插入的細節題
export const BASE_HEAD = [1, 2, 3] // 篩選 / 情境 / 流程
export const DETAIL_STEPS = [4, 5, 6, 7] // 訂票 / 改退 / 報到 / 里程
export const BASE_TAIL = [8, 9, 10, 11] // 故事 / 系統訊息 / 評分 / 開放回饋

// 分支（用「選項在該題的 sortOrder」判斷，比 answerId 穩定）
export const Q1_SCREEN_OUT_OPTION = 2 // Q1「沒用過」→ 直接結尾（不收集）
export const Q3_NONE_OPTION = 5 // Q3「都沒實際做過」→ 跳過 Q4-7
// Q3 流程選項 sortOrder(1-4) → 對應細節題 sortOrder(4-7)
export const Q3_OPTION_TO_DETAIL: Record<number, number> = { 1: 4, 2: 5, 3: 6, 4: 7 }

// 「其他」選項的文字判斷：multiComment 題裡，每個勾選項都可填狀況；這裡先保留常數位置。
