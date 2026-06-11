<script setup lang="ts">
// 題目底部導覽：左「← 上一題」(ghost)、右主要按鈕（下一題 / 送出）。
withDefaults(
    defineProps<{
        showBack?: boolean
        nextLabel: string
        nextDisabled?: boolean
    }>(),
    { showBack: true, nextDisabled: false },
)
defineEmits<{ back: []; next: [] }>()
</script>

<template>
    <div class="mt-10 flex items-center justify-between">
        <button
            v-if="showBack"
            class="text-sm text-muted transition-colors hover:text-text"
            @click="$emit('back')"
        >
            ← {{ $t('common.back') }}
        </button>
        <span v-else />

        <button
            class="rounded-lg bg-primary px-6 py-3 text-sm font-semibold text-white transition-colors hover:bg-primaryhover disabled:cursor-not-allowed disabled:opacity-40"
            :disabled="nextDisabled"
            @click="$emit('next')"
        >
            {{ nextLabel }}
        </button>
    </div>
</template>
