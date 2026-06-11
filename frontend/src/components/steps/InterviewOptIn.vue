<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import { useInterviewStore } from '@/stores/interview'

// Q11 底部：訪談意願 opt-in。勾選後展開稱呼 / Email（寫入 interview store，不落 localStorage）。
const { t } = useI18n()
const interview = useInterviewStore()
</script>

<template>
    <div class="rounded-2xl border border-accent/50 bg-accent/10 px-5 py-4">
        <button
            type="button"
            class="flex w-full items-center gap-3 text-left"
            @click="interview.wantInterview = !interview.wantInterview"
        >
            <span
                class="flex size-5 shrink-0 items-center justify-center rounded border-2 text-white"
                :class="
                    interview.wantInterview
                        ? 'border-accent bg-accent'
                        : 'border-muted bg-transparent'
                "
            >
                <span v-if="interview.wantInterview" class="text-xs leading-none">✓</span>
            </span>
            <span class="flex-1 text-text">{{ t('interview.title') }}</span>
        </button>

        <Transition name="expand">
            <div v-if="interview.wantInterview" class="expand-grid">
                <div class="expand-inner">
                    <div class="mt-4 space-y-3">
                        <input
                            v-model="interview.name"
                            name="interview-name"
                            autocomplete="name"
                            :placeholder="t('interview.namePlaceholder')"
                            class="w-full rounded-xl border border-border bg-bg px-4 py-2.5 text-sm text-text placeholder:text-muted focus:border-accent focus:outline-none"
                        />
                        <input
                            v-model="interview.email"
                            name="interview-email"
                            type="email"
                            autocomplete="email"
                            :placeholder="t('interview.emailPlaceholder')"
                            class="w-full rounded-xl border border-border bg-bg px-4 py-2.5 text-sm text-text placeholder:text-muted focus:border-accent focus:outline-none"
                        />
                    </div>
                </div>
            </div>
        </Transition>
    </div>
</template>

<style scoped>
.expand-grid {
    display: grid;
}
.expand-inner {
    overflow: hidden;
    min-height: 0;
}
.expand-enter-active,
.expand-leave-active {
    transition:
        grid-template-rows 0.24s ease,
        opacity 0.24s ease;
}
.expand-enter-from,
.expand-leave-to {
    grid-template-rows: 0fr;
    opacity: 0;
}
.expand-enter-to,
.expand-leave-from {
    grid-template-rows: 1fr;
    opacity: 1;
}
</style>
