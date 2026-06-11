<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { setLocale } from '@/i18n'
import { setDark } from '@/lib/theme'

// 全站外殼：頂部進度條、左上 v4 標記、右上（進度文字 / 完成）＋ 語言/主題切換、置中內容。
const props = withDefaults(
    defineProps<{
        showProgress?: boolean
        current?: number
        total?: number
        rightLabel?: string
    }>(),
    { showProgress: false, current: 0, total: 0, rightLabel: '' },
)

const { t, locale } = useI18n()

const isDark = ref(document.documentElement.classList.contains('dark'))
function toggleDark() {
    isDark.value = !isDark.value
    setDark(isDark.value) // 切換 .dark + 記到 localStorage
}
function toggleLocale() {
    setLocale(locale.value === 'zh' ? 'en' : 'zh')
}

function progressPct(): number {
    if (!props.total) return 0
    return Math.round((props.current / props.total) * 100)
}
</script>

<template>
    <div class="flex min-h-screen flex-col bg-bg text-text">
        <!-- 頂部進度條 -->
        <div class="h-1 w-full bg-border">
            <div
                v-if="showProgress"
                class="h-full bg-primary transition-[width] duration-300"
                :style="{ width: progressPct() + '%' }"
            />
        </div>

        <!-- 頁首：進度文字＋切換（靠右） -->
        <header class="flex items-center justify-end px-5 py-3">
            <div class="flex items-center gap-3">
                <span v-if="showProgress" class="text-sm text-muted">
                    {{ t('progress.stepOf', { current, total }) }}
                </span>
                <span v-else-if="rightLabel" class="text-sm font-medium text-muted">
                    {{ rightLabel }}
                </span>
                <button
                    class="rounded-lg border border-border px-2.5 py-1 text-sm transition-colors hover:bg-surface"
                    @click="toggleLocale"
                >
                    {{ locale === 'zh' ? 'EN' : '中' }}
                </button>
                <button
                    class="rounded-lg border border-border px-2.5 py-1 text-sm transition-colors hover:bg-surface"
                    :aria-label="isDark ? 'Light mode' : 'Dark mode'"
                    @click="toggleDark"
                >
                    {{ isDark ? '☀️' : '🌙' }}
                </button>
            </div>
        </header>

        <!-- 內容置中 -->
        <main class="flex flex-1 items-center justify-center px-6 pb-16">
            <div class="w-full max-w-2xl">
                <slot />
            </div>
        </main>
    </div>
</template>
