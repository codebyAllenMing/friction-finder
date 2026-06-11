import { defineStore } from 'pinia'
import { computed, ref } from 'vue'

// 訪談意願（PII）獨立成一個 store：邏輯隔離、送出時對應後端的 SurveyInterview。
// 不存 localStorage（純記憶體），重整後使用者重填即可。
export const useInterviewStore = defineStore('interview', () => {
    const wantInterview = ref(false)
    const name = ref('')
    const email = ref('')

    // 沒勾 → 一律有效；勾了 → 稱呼與 Email 都要填
    const isValid = computed(
        () => !wantInterview.value || (name.value.trim() !== '' && email.value.trim() !== ''),
    )

    function reset() {
        wantInterview.value = false
        name.value = ''
        email.value = ''
    }

    return { wantInterview, name, email, isValid, reset }
})
