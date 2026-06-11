<script setup lang="ts">
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { setLocale } from '@/i18n'
import airplane from '@/assets/airplane-404.png'

// 404 頁：文字全用 i18n。RWD —
//   桌機：整張插畫當背景(飛機靠右)+ 文字疊左側乾淨天空
//   手機：堆疊，上文字、下飛機(避免直立螢幕把飛機放超大壓到文字)
const router = useRouter()
const { t, locale } = useI18n()

function goHome() {
    router.push('/')
}
function toggleLocale() {
    setLocale(locale.value === 'zh' ? 'en' : 'zh')
}
</script>

<template>
    <div class="relative min-h-screen overflow-hidden bg-[#4ea7ef]">
        <!-- 語言切換 -->
        <button
            class="absolute right-5 top-5 z-30 rounded-lg bg-white/20 px-3 py-1.5 text-sm font-medium text-white backdrop-blur transition hover:bg-white/30"
            @click="toggleLocale"
        >
            {{ locale === 'zh' ? 'EN' : '中' }}
        </button>

        <!-- 桌機：整張當背景 + 左濃右淡遮罩(手機隱藏) -->
        <img
            :src="airplane"
            alt=""
            class="pointer-events-none absolute inset-0 hidden h-full w-full object-cover object-right md:block"
        />
        <div
            class="pointer-events-none absolute inset-0 hidden bg-gradient-to-r from-[#4ea7ef] from-15% via-[#4ea7ef]/55 to-transparent to-70% md:block"
        />

        <!-- 內容 -->
        <div class="relative z-10 flex min-h-screen flex-col">
            <!-- 文字 -->
            <div class="px-8 pt-24 md:flex md:flex-1 md:items-center md:px-16 md:pt-0">
                <div class="max-w-lg">
                    <h1 class="text-7xl font-extrabold text-white drop-shadow-lg md:text-8xl">
                        404
                    </h1>
                    <p class="mt-4 text-xl font-bold leading-snug text-white drop-shadow md:text-2xl">
                        {{ t('notFound.lead') }}
                    </p>
                    <p class="mt-2 text-white/90 drop-shadow">{{ t('notFound.sub') }}</p>
                    <button
                        class="mt-8 inline-flex items-center gap-2 rounded-full bg-[#ffd23f] px-6 py-3 font-bold text-[#1b4a8a] shadow-lg transition hover:bg-[#ffda5e]"
                        @click="goHome"
                    >
                        <span>🏠</span> {{ t('notFound.goHome') }}
                    </button>
                </div>
            </div>

            <!-- 手機：飛機放底部(桌機改用背景圖，故隱藏) -->
            <img
                :src="airplane"
                alt=""
                class="mt-auto h-72 w-full object-cover object-right md:hidden"
            />
        </div>
    </div>
</template>
