<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { getManuals, type ManualSummary } from '@/api/manuals'

const router = useRouter()
const route = useRoute()
const manuals = ref<ManualSummary[]>([])
const loading = ref(false)
const searchQuery = ref('')
const selectedTags = ref<string[]>([])
const sortBy = ref('updated_at')

// APIからデータ取得とURLパラメータの処理
onMounted(async () => {
  // URLパラメータから検索ワードを取得
  if (route.query.q) {
    searchQuery.value = String(route.query.q)
  }
  
  loading.value = true
  try {
    manuals.value = await getManuals()
  } catch (error) {
    console.error('Failed to load manuals:', error)
  } finally {
    loading.value = false
  }
})

// 全てのタグを取得
const allTags = computed(() => {
  const tags = new Set<string>()
  manuals.value.forEach(manual => {
    manual.tags.forEach(tag => tags.add(tag.name))
  })
  return Array.from(tags).sort()
})

// フィルタリング後のマニュアル
const filteredManuals = computed(() => {
  let filtered = manuals.value

  // 検索キーワードでフィルタ
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(manual => 
      manual.title.toLowerCase().includes(query) ||
      manual.description.toLowerCase().includes(query) ||
      manual.tags.some(tag => tag.name.toLowerCase().includes(query))
    )
  }

  // タグでフィルタ
  if (selectedTags.value.length > 0) {
    filtered = filtered.filter(manual =>
      selectedTags.value.every(tagName =>
        manual.tags.some(tag => tag.name === tagName)
      )
    )
  }

  // ソート
  return [...filtered].sort((a, b) => {
    if (sortBy.value === 'updated_at') {
      return new Date(b.updated_at).getTime() - new Date(a.updated_at).getTime()
    } else if (sortBy.value === 'title') {
      return a.title.localeCompare(b.title, 'ja')
    } else if (sortBy.value === 'step_count') {
      return b.step_count - a.step_count
    }
    return 0
  })
})

// 相対時間表示
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

const navigateToManual = (id: number) => {
  router.push(`/manuals/${id}`)
}

const createManual = () => {
  router.push('/manuals/new')
}

const clearFilters = () => {
  searchQuery.value = ''
  selectedTags.value = []
}
</script>

<template>
  <v-container>
    <!-- ヘッダー -->
    <v-row class="mb-6">
      <v-col>
        <h1 class="text-h4">マニュアル一覧</h1>
        <p class="text-grey mt-2">すべてのマニュアルを検索・閲覧できます</p>
      </v-col>
      <v-col cols="auto">
        <v-btn
          color="primary"
          prepend-icon="mdi-plus"
          @click="createManual"
        >
          新規作成
        </v-btn>
      </v-col>
    </v-row>

    <!-- フィルター -->
    <v-card class="mb-6">
      <v-card-text>
        <v-row>
          <v-col cols="12" md="6">
            <v-text-field
              v-model="searchQuery"
              label="検索"
              prepend-inner-icon="mdi-magnify"
              variant="outlined"
              density="compact"
              clearable
              hide-details
            />
          </v-col>
          <v-col cols="12" md="3">
            <v-select
              v-model="selectedTags"
              :items="allTags"
              label="タグで絞り込み"
              variant="outlined"
              density="compact"
              multiple
              chips
              closable-chips
              hide-details
            />
          </v-col>
          <v-col cols="12" md="3">
            <v-select
              v-model="sortBy"
              :items="[
                { title: '更新日時順', value: 'updated_at' },
                { title: 'タイトル順', value: 'title' },
                { title: 'ステップ数順', value: 'step_count' }
              ]"
              label="並び順"
              variant="outlined"
              density="compact"
              hide-details
            />
          </v-col>
        </v-row>
        <v-row v-if="searchQuery || selectedTags.length > 0" class="mt-2">
          <v-col>
            <v-chip
              size="small"
              closable
              @click:close="clearFilters"
            >
              フィルターをクリア
            </v-chip>
          </v-col>
        </v-row>
      </v-card-text>
    </v-card>

    <!-- ローディング -->
    <v-row v-if="loading">
      <v-col class="text-center">
        <v-progress-circular indeterminate color="primary" />
      </v-col>
    </v-row>

    <!-- マニュアルリスト -->
    <v-row v-else-if="filteredManuals.length > 0">
      <v-col cols="12">
        <div class="text-grey mb-2">
          {{ filteredManuals.length }}件のマニュアル
        </div>
      </v-col>
      <v-col
        v-for="manual in filteredManuals"
        :key="manual.id"
        cols="12"
        md="6"
        lg="4"
      >
        <v-card
          elevation="2"
          @click="navigateToManual(manual.id)"
          style="cursor: pointer; height: 100%;"
        >
          <v-img
            v-if="manual.thumbnail_url"
            :src="manual.thumbnail_url"
            height="200"
            cover
          />
          <v-card-text>
            <h3 class="text-h6 mb-2">{{ manual.title }}</h3>
            <p class="text-body-2 text-grey-darken-1 mb-3">
              {{ manual.description }}
            </p>
            
            <!-- タグ -->
            <v-chip-group class="mb-2">
              <v-chip
                v-for="tag in manual.tags"
                :key="tag.id"
                size="small"
                variant="outlined"
              >
                {{ tag.name }}
              </v-chip>
            </v-chip-group>
            
            <!-- メタ情報 -->
            <div class="d-flex justify-space-between align-center text-caption text-grey">
              <span>
                <v-icon size="x-small">mdi-file-document-multiple-outline</v-icon>
                {{ manual.step_count }}ステップ
              </span>
              <span>{{ formatRelativeTime(manual.updated_at) }}</span>
            </div>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <!-- データがない場合 -->
    <v-row v-else>
      <v-col class="text-center py-8">
        <v-icon size="80" color="grey">mdi-file-document-outline</v-icon>
        <p class="text-h6 mt-4">
          {{ searchQuery || selectedTags.length > 0 ? '条件に一致するマニュアルがありません' : 'まだマニュアルがありません' }}
        </p>
        <v-btn
          v-if="searchQuery || selectedTags.length > 0"
          variant="text"
          @click="clearFilters"
          class="mt-2"
        >
          フィルターをクリア
        </v-btn>
      </v-col>
    </v-row>
  </v-container>
</template>