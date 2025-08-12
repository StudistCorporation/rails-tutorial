<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getManuals, type ManualSummary } from '@/api/manuals'

const router = useRouter()
const searchQuery = ref('')

// APIからデータを取得
const allManuals = ref<ManualSummary[]>([])
const loading = ref(false)

onMounted(async () => {
  loading.value = true
  try {
    allManuals.value = await getManuals()
  } catch (error) {
    console.error('Failed to load manuals:', error)
  } finally {
    loading.value = false
  }
})

// 表示用の計算プロパティ
const popularManuals = computed(() => 
  // とりあえず最初の3件を表示（後で閲覧数でソート）
  allManuals.value.slice(0, 3)
)
const recentManuals = computed(() => 
  // 更新日時でソート
  [...allManuals.value].sort((a, b) => 
    new Date(b.updated_at).getTime() - new Date(a.updated_at).getTime()
  ).slice(0, 3)
)

const navigateToManual = (id: number) => {
  router.push(`/manuals/${id}`)
}

const createManual = () => {
  router.push('/manuals/new')
}

// 検索ボックスでEnterキーが押されたときの処理
const handleSearch = () => {
  if (searchQuery.value.trim()) {
    router.push({
      path: '/manuals',
      query: { q: searchQuery.value.trim() }
    })
  }
}

// 相対時間表示のヘルパー
const formatRelativeTime = (dateStr: string): string => {
  const date = new Date(dateStr)
  const now = new Date()
  const diff = now.getTime() - date.getTime()
  const minutes = Math.floor(diff / 60000)
  const hours = Math.floor(diff / 3600000)
  const days = Math.floor(diff / 86400000)
  
  if (minutes < 60) return `${minutes}分前`
  if (hours < 24) return `${hours}時間前`
  if (days < 7) return `${days}日前`
  return date.toLocaleDateString('ja-JP')
}
</script>

<template>
  <v-container class="py-8">
    <!-- ヘッダー -->
    <v-row class="mb-8">
      <v-col cols="12" class="text-center">
        <h1 class="text-h3 font-weight-bold mb-2">
          <v-icon color="primary" size="40">mdi-book-open-variant</v-icon>
          Awesome Manual
        </h1>
        <p class="text-subtitle-1 text-grey">みんなの知識をシンプルに</p>
      </v-col>
    </v-row>

    <!-- 検索ボックス -->
    <v-row class="mb-8">
      <v-col cols="12" md="8" offset-md="2">
        <v-text-field
          v-model="searchQuery"
          variant="solo"
          placeholder="何について知りたい？"
          prepend-inner-icon="mdi-magnify"
          hide-details
          class="elevation-2"
          @keyup.enter="handleSearch"
        >
          <template v-slot:append-inner>
            <v-chip size="small" variant="text" class="text-caption">
              例：新人研修、経費精算、デプロイ手順...
            </v-chip>
          </template>
        </v-text-field>
      </v-col>
    </v-row>

    <!-- ローディング -->
    <v-row v-if="loading" class="mb-8">
      <v-col cols="12" class="text-center">
        <v-progress-circular indeterminate color="primary" />
      </v-col>
    </v-row>

    <!-- よく見られている -->
    <v-row v-else-if="allManuals.length > 0" class="mb-8">
      <v-col cols="12" class="d-flex justify-space-between align-center">
        <h2 class="text-h5">
          <v-icon size="small" class="mr-2">mdi-fire</v-icon>
          よく見られている
        </h2>
        <v-btn
          variant="text"
          to="/manuals"
          append-icon="mdi-arrow-right"
        >
          すべて見る
        </v-btn>
      </v-col>
      <v-col v-for="manual in popularManuals" :key="manual.id" cols="12" sm="4">
        <v-card 
          elevation="2"
          @click="navigateToManual(manual.id)"
          style="cursor: pointer;"
        >
          <v-img
            v-if="manual.thumbnail_url"
            :src="manual.thumbnail_url"
            height="200"
            cover
          >
          </v-img>
          <v-card-text>
            <h3 class="text-h6 mb-1">{{ manual.title }}</h3>
            <p class="text-body-2 text-grey-darken-1 mb-2">{{ manual.description }}</p>
            <div class="d-flex align-center justify-space-between">
              <v-chip-group>
                <v-chip
                  v-for="tag in manual.tags.slice(0, 2)"
                  :key="tag.id"
                  size="x-small"
                  variant="outlined"
                >
                  {{ tag.name }}
                </v-chip>
              </v-chip-group>
              <span class="text-caption text-grey">
                <v-icon size="x-small">mdi-file-document-multiple-outline</v-icon>
                {{ manual.step_count }}ステップ
              </span>
            </div>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <!-- 最近追加された -->
    <v-row v-if="!loading && allManuals.length > 0" class="mb-8">
      <v-col cols="12">
        <h2 class="text-h5 mb-4">
          <v-icon size="small" class="mr-2">mdi-sparkles</v-icon>
          最近更新された
        </h2>
      </v-col>
      <v-col cols="12">
        <v-list lines="two">
          <v-list-item
            v-for="manual in recentManuals"
            :key="manual.id"
            @click="navigateToManual(manual.id)"
            class="px-0"
          >
            <template v-slot:prepend>
              <v-icon>mdi-file-document-outline</v-icon>
            </template>
            <v-list-item-title>{{ manual.title }}</v-list-item-title>
            <v-list-item-subtitle>{{ manual.description }}</v-list-item-subtitle>
            <template v-slot:append>
              <span class="text-caption text-grey">{{ formatRelativeTime(manual.updated_at) }}</span>
            </template>
          </v-list-item>
        </v-list>
      </v-col>
    </v-row>

    <!-- データがない場合 -->
    <v-row v-if="!loading && allManuals.length === 0" class="mb-8">
      <v-col cols="12" class="text-center">
        <v-icon size="80" color="grey">mdi-file-document-outline</v-icon>
        <p class="text-h6 mt-4">まだマニュアルがありません</p>
      </v-col>
    </v-row>

    <!-- マニュアル作成ボタン -->
    <v-row>
      <v-col cols="12" class="text-center">
        <v-btn
          color="primary"
          size="large"
          prepend-icon="mdi-plus"
          @click="createManual"
        >
          マニュアルを作る
        </v-btn>
      </v-col>
    </v-row>
  </v-container>
</template>
