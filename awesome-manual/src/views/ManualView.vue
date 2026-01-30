<script setup lang="ts">
import { onMounted, ref, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getManual, type Manual } from '@/api/manuals'

const route = useRoute()
const router = useRouter()


const manual = ref<Manual | null>(null)
const expandedSteps = ref<number[]>([])
const loading = ref(true)

// ステップの展開/折りたたみ
const toggleStep = (stepId: number) => {
  const index = expandedSteps.value.indexOf(stepId)
  if (index > -1) {
    expandedSteps.value.splice(index, 1)
  } else {
    expandedSteps.value.push(stepId)
  }
}

const isStepExpanded = (stepId: number) => {
  return expandedSteps.value.includes(stepId)
}

// パンくずリスト用
const breadcrumbs = computed(() => [
  { title: 'ホーム', disabled: false, to: '/' },
  { title: manual.value?.title || '', disabled: true }
])

onMounted(async () => {
  const manualId = route.params.id as string
  loading.value = true
  try {
    manual.value = await getManual(manualId)
    // 最初のステップは展開しておく
    const firstStep = manual.value.steps[0]
    if (firstStep?.id) {
      expandedSteps.value.push(firstStep.id)
    }
  } catch (error) {
    console.error('Failed to load manual:', error)
  } finally {
    loading.value = false
  }
})

const goBack = () => {
  router.push('/')
}

const shareManual = () => {
  // 共有機能（後で実装）
  console.log('Share manual:', manual.value?.id)
}

const editManual = () => {
  router.push(`/manuals/${manual.value?.id}/edit`)
}
</script>

<template>
  <v-container class="pa-0" fluid>
    <!-- ローディング -->
    <v-container v-if="loading" class="text-center py-8">
      <v-progress-circular indeterminate color="primary" />
    </v-container>

    <!-- メインコンテンツ -->
    <div v-else-if="manual">
      <!-- ヘッダー画像 -->
      <v-img
        :src="manual.thumbnail_url || 'https://picsum.photos/800/400?random=1'"
        height="300"
        cover
        class="mb-4"
      >
        <v-container class="fill-height">
          <v-row align="end">
            <v-col>
              <h1 class="text-h3 text-white font-weight-bold">{{ manual.title }}</h1>
            </v-col>
          </v-row>
        </v-container>
      </v-img>

      <v-container>
        <!-- パンくずリスト -->
        <v-breadcrumbs :items="breadcrumbs" class="px-0">
          <template v-slot:divider>
            <v-icon icon="mdi-chevron-right"></v-icon>
          </template>
        </v-breadcrumbs>

        <v-row>
          <!-- メインコンテンツ -->
          <v-col cols="12" md="8">
            <!-- 概要 -->
            <v-card class="mb-4" elevation="0">
              <v-card-text>
                <p class="text-body-1">{{ manual.description }}</p>
                
                <!-- メタ情報 -->
                <v-row class="mt-4">
                  <v-col cols="auto">
                    <v-chip size="small" prepend-icon="mdi-calendar">
                      更新日: {{ manual.updated_at ? new Date(manual.updated_at).toLocaleDateString('ja-JP') : '' }}
                    </v-chip>
                  </v-col>
                  <v-col cols="auto">
                    <v-chip size="small" prepend-icon="mdi-file-document-multiple-outline">
                      {{ manual.steps.length }}ステップ
                    </v-chip>
                  </v-col>
                </v-row>

                <!-- タグ -->
                <div class="mt-3">
                  <v-chip
                    v-for="tag in manual.tags"
                    :key="tag.id"
                    size="small"
                    class="mr-2"
                    color="primary"
                    variant="outlined"
                  >
                    {{ tag.name }}
                  </v-chip>
                </div>
              </v-card-text>
            </v-card>

            <!-- ステップ一覧 -->
            <h2 class="text-h5 mb-4">手順</h2>
            <v-expansion-panels
              v-model="expandedSteps"
              multiple
              variant="accordion"
            >
              <v-expansion-panel
                v-for="(step, index) in manual.steps"
                :key="step.id"
                :value="step.id"
              >
                <v-expansion-panel-title>
                  <div class="d-flex align-center">
                    <v-avatar
                      color="primary"
                      size="32"
                      class="mr-3"
                    >
                      {{ index + 1 }}
                    </v-avatar>
                    <span class="text-h6">{{ step.title }}</span>
                  </div>
                </v-expansion-panel-title>
                <v-expansion-panel-text>
                  <div class="pt-4">
                    <p class="mb-4">{{ step.description }}</p>
                    
                    <!-- ステップ画像 -->
                    <v-img
                      v-if="step.image_url"
                      :src="step.image_url"
                      class="mb-4 rounded"
                      max-height="400"
                      contain
                    />
                  </div>
                </v-expansion-panel-text>
              </v-expansion-panel>
            </v-expansion-panels>
          </v-col>

          <!-- サイドバー -->
          <v-col cols="12" md="4">
            <!-- アクションボタン -->
            <v-card class="mb-4">
              <v-card-text>
                <v-btn
                  color="primary"
                  block
                  prepend-icon="mdi-pencil"
                  @click="editManual"
                  class="mb-2"
                >
                  編集する
                </v-btn>
                <v-btn
                  variant="outlined"
                  block
                  prepend-icon="mdi-share-variant"
                  @click="shareManual"
                >
                  共有する
                </v-btn>
              </v-card-text>
            </v-card>

            <!-- 目次 -->
            <v-card>
              <v-card-title class="text-h6">目次</v-card-title>
              <v-list density="compact">
                <v-list-item
                  v-for="(step, index) in manual.steps"
                  :key="step.id ?? index"
                  @click="() => {
                    if (step.id !== undefined && !isStepExpanded(step.id)) {
                      toggleStep(step.id)
                    }
                  }"
                >
                  <template v-slot:prepend>
                    <span class="text-caption mr-2">{{ index + 1 }}.</span>
                  </template>
                  <v-list-item-title class="text-body-2">
                    {{ step.title }}
                  </v-list-item-title>
                </v-list-item>
              </v-list>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </div>
  </v-container>
</template>
