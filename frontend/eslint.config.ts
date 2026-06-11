import pluginVue from 'eslint-plugin-vue'
import { defineConfigWithVueTs, vueTsConfigs } from '@vue/eslint-config-typescript'
import skipFormatting from '@vue/eslint-config-prettier/skip-formatting'

export default defineConfigWithVueTs(
    {
        name: 'app/files-to-lint',
        files: ['**/*.{ts,mts,tsx,vue}'],
    },
    {
        name: 'app/files-to-ignore',
        ignores: ['**/dist/**', '**/dist-ssr/**', '**/coverage/**', '**/src/data/**'],
    },

    // Vue 基本規則
    pluginVue.configs['flat/essential'],
    // TypeScript 推薦規則（非 type-checked，快）
    vueTsConfigs.recommended,
    // 關掉所有跟 Prettier 衝突的排版規則 → 排版交給 Prettier
    skipFormatting,
)
