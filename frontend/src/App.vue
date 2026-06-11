<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { setLocale } from '@/i18n'

const { t, locale } = useI18n()

const isDark = ref(document.documentElement.classList.contains('dark'))
function toggleDark() {
    isDark.value = !isDark.value
    document.documentElement.classList.toggle('dark', isDark.value)
}

function toggleLocale() {
    setLocale(locale.value === 'zh' ? 'en' : 'zh')
}
</script>

<template>
    <div class="min-h-screen bg-bg text-text">
        <!-- 右上角：主題 + 語言切換 -->
        <div class="fixed right-4 top-4 z-10 flex gap-2">
            <button
                class="rounded-lg border border-border px-3 py-1.5 text-sm transition-colors hover:bg-surface"
                :aria-label="isDark ? 'Light mode' : 'Dark mode'"
                @click="toggleDark"
            >
                {{ isDark ? '☀️' : '🌙' }}
            </button>
            <button
                class="rounded-lg border border-border px-3 py-1.5 text-sm transition-colors hover:bg-surface"
                @click="toggleLocale"
            >
                {{ locale === 'zh' ? 'EN' : '中' }}
            </button>
        </div>

        <!-- 主要內容 -->
        <div class="flex min-h-screen flex-col items-center justify-center gap-6 px-6 text-center">
            <h1 class="text-4xl font-bold text-accent">Friction Finder</h1>
            <p class="text-xl">{{ t('intro.title') }}</p>
            <p class="max-w-xl text-muted">{{ t('intro.desc') }}</p>
        </div>
    </div>
</template>
