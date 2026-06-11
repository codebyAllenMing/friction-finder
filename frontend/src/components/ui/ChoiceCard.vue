<script setup lang="ts">
// 單一選項卡片：單選用圓鈕(radio)、複選用方框(check)。
// dashed = 分支型選項（沒用過 / 都沒做過）用虛線框；badge = 右側分支標籤。
withDefaults(
    defineProps<{
        label: string
        selected?: boolean
        control?: 'radio' | 'check'
        dashed?: boolean
        badge?: string
        disabled?: boolean
    }>(),
    { selected: false, control: 'radio', dashed: false, badge: '', disabled: false },
)
defineEmits<{ toggle: [] }>()
</script>

<template>
    <button
        type="button"
        :disabled="disabled"
        class="flex w-full items-center gap-3 rounded-2xl border px-5 py-4 text-left transition-colors disabled:cursor-not-allowed disabled:opacity-45"
        :class="[
            dashed ? 'border-dashed' : 'border-solid',
            selected
                ? 'border-primary bg-primarysoft shadow-sm ring-1 ring-primary'
                : disabled
                  ? 'border-border bg-surface'
                  : 'border-border bg-surface hover:border-primary/40 hover:bg-surface',
        ]"
        @click="$emit('toggle')"
    >
        <!-- 控制項 -->
        <span
            class="flex size-5 shrink-0 items-center justify-center border-2 text-white"
            :class="[
                control === 'radio' ? 'rounded-full' : 'rounded',
                selected ? 'border-primary bg-primary' : 'border-muted bg-transparent',
            ]"
        >
            <span
                v-if="selected && control === 'radio'"
                class="size-2 rounded-full bg-white"
            />
            <span v-else-if="selected" class="text-xs leading-none">✓</span>
        </span>

        <span class="flex-1 text-text" :class="selected ? 'font-medium' : ''">{{ label }}</span>

        <span
            v-if="badge"
            class="rounded bg-dangersoft px-2 py-1 text-xs font-medium text-danger"
        >
            {{ badge }}
        </span>
    </button>
</template>
