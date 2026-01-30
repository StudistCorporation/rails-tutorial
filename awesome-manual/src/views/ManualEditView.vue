<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getManual, updateManual, type Manual, type Tag } from '@/api/manuals'

const route = useRoute()
const router = useRouter()

// フォームデータ
const manual = ref<Manual>({
  id: 0,
  title: '',
  description: '',
  tags: [] as Tag[],
  steps: []
})

// サムネイル画像用
const thumbnailFile = ref<File | null>(null)
const thumbnailPreview = ref<string>('')

// ステップ画像用
const stepImages = ref<Record<number, { file: File | null, preview: string }>>({})

const loading = ref(false)
const saving = ref(false)

// タグ入力用
const tagInput = ref('')
const availableTags = ref(['研修', '新人教育', 'オンボーディング', '人事', '総務', '開発'])
const isComposing = ref(false)

// APIからデータを取得
onMounted(async () => {
  const manualId = route.params.id as string
  loading.value = true
  try {
    manual.value = await getManual(manualId)
    // 既存のサムネイルを表示
    if (manual.value.thumbnail_url) {
      thumbnailPreview.value = manual.value.thumbnail_url
    }
    // 既存のステップ画像を追跡
    manual.value.steps.forEach((step, index) => {
      if (step.image_url) {
        stepImages.value[index] = { file: null, preview: step.image_url }
      }
    })
  } catch (error) {
    console.error('Failed to load manual:', error)
    // エラーハンドリング（後で改善）
  } finally {
    loading.value = false
  }
})

// ステップの追加
const addStep = () => {
  const maxPosition = manual.value.steps.length > 0 
    ? Math.max(...manual.value.steps.map(s => s.position || 0))
    : 0
  
  manual.value.steps.push({
    title: '',
    description: '',
    position: maxPosition + 1
  })
}

// ステップの削除
const removeStep = (index: number) => {
  const step = manual.value.steps[index]
  if (!step) return

  if (step.id) {
    // 既存のステップは削除フラグを立てる
    step._destroy = true
  } else {
    // 新規ステップは配列から削除
    manual.value.steps.splice(index, 1)
  }
}

// ステップの移動
const moveStep = (index: number, direction: 'up' | 'down') => {
  const newIndex = direction === 'up' ? index - 1 : index + 1
  const currentStep = manual.value.steps[index]
  const targetStep = manual.value.steps[newIndex]
  if (newIndex >= 0 && newIndex < manual.value.steps.length && currentStep && targetStep) {
    manual.value.steps[index] = targetStep
    manual.value.steps[newIndex] = currentStep
  }
}

// タグの追加
const addTag = () => {
  if (tagInput.value && !manual.value.tags.find(t => t.name === tagInput.value)) {
    // 仮のIDを付与（バックエンドで新規作成される）
    manual.value.tags.push({ id: Date.now(), name: tagInput.value })
    if (!availableTags.value.includes(tagInput.value)) {
      availableTags.value.push(tagInput.value)
    }
    tagInput.value = ''
  }
}

// IME対応のEnterキー処理
const handleTagEnter = (event: KeyboardEvent) => {
  // IME変換中は何もしない
  if (isComposing.value || event.isComposing) {
    return
  }
  addTag()
}

// タグの削除
const removeTag = (tag: Tag) => {
  const index = manual.value.tags.findIndex(t => t.id === tag.id)
  if (index > -1) {
    manual.value.tags.splice(index, 1)
  }
}

// 保存処理
const save = async () => {
  saving.value = true
  try {
    const manualId = route.params.id as string
    
    // positionを更新
    manual.value.steps.forEach((step, index) => {
      if (!step._destroy) {
        step.position = index + 1
      }
    })
    
    await updateManual(manualId, manual.value, thumbnailFile.value, stepImages.value)
    router.push(`/manuals/${manualId}`)
  } catch (error) {
    console.error('Failed to save manual:', error)
    // エラーハンドリング（後で改善）
  } finally {
    saving.value = false
  }
}

// キャンセル
const cancel = () => {
  router.push(`/manuals/${route.params.id}`)
}

// 画像ファイル選択時の処理
const handleThumbnailChange = (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  
  if (file) {
    // ファイルサイズ制限（5MB）
    if (file.size > 5 * 1024 * 1024) {
      alert('ファイルサイズは5MB以下にしてください')
      return
    }
    
    // ファイル形式チェック
    if (!file.type.startsWith('image/')) {
      alert('画像ファイルを選択してください')
      return
    }
    
    thumbnailFile.value = file
    
    // プレビュー表示
    const reader = new FileReader()
    reader.onload = (e) => {
      thumbnailPreview.value = e.target?.result as string
    }
    reader.readAsDataURL(file)
  }
}

// サムネイル削除
const removeThumbnail = () => {
  thumbnailFile.value = null
  thumbnailPreview.value = ''
}

// ステップ画像選択時の処理
const handleStepImageChange = (stepIndex: number, event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  
  if (file) {
    // ファイルサイズ制限（5MB）
    if (file.size > 5 * 1024 * 1024) {
      alert('ファイルサイズは5MB以下にしてください')
      return
    }
    
    // ファイル形式チェック
    if (!file.type.startsWith('image/')) {
      alert('画像ファイルを選択してください')
      return
    }
    
    // プレビュー表示
    const reader = new FileReader()
    reader.onload = (e) => {
      if (!stepImages.value[stepIndex]) {
        stepImages.value[stepIndex] = { file: null, preview: '' }
      }
      stepImages.value[stepIndex].file = file
      stepImages.value[stepIndex].preview = e.target?.result as string
    }
    reader.readAsDataURL(file)
  }
}

// ステップ画像削除
const removeStepImage = (stepIndex: number) => {
  if (stepImages.value[stepIndex]) {
    stepImages.value[stepIndex].file = null
    stepImages.value[stepIndex].preview = ''
  }
}

// 表示用のステップ（削除フラグが立っていないもの）
const visibleSteps = computed(() => 
  manual.value.steps.filter(step => !step._destroy)
)
</script>

<template>
  <v-container>
    <!-- ローディング -->
    <v-container v-if="loading" class="text-center py-8">
      <v-progress-circular indeterminate color="primary" />
    </v-container>

    <!-- 編集フォーム -->
    <div v-else>
      <v-row class="mb-4">
        <v-col>
          <h1 class="text-h4">マニュアルを編集</h1>
        </v-col>
      </v-row>

      <v-form @submit.prevent="save">
        <!-- 基本情報 -->
        <v-card class="mb-6">
          <v-card-title>基本情報</v-card-title>
          <v-card-text>
            <v-text-field
              v-model="manual.title"
              label="タイトル"
              required
              variant="outlined"
              class="mb-4"
            />
            
            <v-textarea
              v-model="manual.description"
              label="説明"
              rows="3"
              variant="outlined"
              class="mb-4"
            />

            <!-- サムネイル画像 -->
            <div class="mb-4">
              <v-label class="mb-2">サムネイル画像</v-label>
              
              <!-- プレビュー -->
              <v-card v-if="thumbnailPreview" class="mb-3" variant="outlined">
                <v-img
                  :src="thumbnailPreview"
                  height="200"
                  cover
                />
                <v-card-actions>
                  <v-btn
                    variant="text"
                    color="error"
                    @click="removeThumbnail"
                  >
                    画像を削除
                  </v-btn>
                </v-card-actions>
              </v-card>
              
              <!-- アップロードボタン -->
              <v-file-input
                v-show="!thumbnailPreview"
                accept="image/*"
                label="画像を選択"
                variant="outlined"
                prepend-icon="mdi-camera"
                @change="handleThumbnailChange"
              />
            </div>

            <!-- タグ -->
            <div class="mb-4">
              <v-label class="mb-2">タグ</v-label>
              <v-chip-group>
                <v-chip
                  v-for="tag in manual.tags"
                  :key="tag.id"
                  closable
                  @click:close="removeTag(tag)"
                >
                  {{ tag.name }}
                </v-chip>
              </v-chip-group>
              
              <v-combobox
                v-model="tagInput"
                :items="availableTags"
                label="タグを追加"
                variant="outlined"
                density="compact"
                @compositionstart="isComposing = true"
                @compositionend="isComposing = false"
                @keyup.enter="handleTagEnter"
                class="mt-2"
              />
            </div>
          </v-card-text>
        </v-card>

        <!-- ステップ -->
        <v-card>
          <v-card-title class="d-flex justify-space-between align-center">
            <span>手順</span>
            <v-btn
              color="primary"
              variant="text"
              prepend-icon="mdi-plus"
              @click="addStep"
            >
              ステップを追加
            </v-btn>
          </v-card-title>
          
          <v-card-text>
            <div
              v-for="(step, index) in visibleSteps"
              :key="index"
              class="mb-4 pa-4 border rounded"
            >
              <div class="d-flex justify-space-between align-center mb-2">
                <h3 class="text-h6">ステップ {{ index + 1 }}</h3>
                <div>
                  <v-btn
                    icon="mdi-arrow-up"
                    size="small"
                    variant="text"
                    :disabled="index === 0"
                    @click="moveStep(index, 'up')"
                  />
                  <v-btn
                    icon="mdi-arrow-down"
                    size="small"
                    variant="text"
                    :disabled="index === visibleSteps.length - 1"
                    @click="moveStep(index, 'down')"
                  />
                  <v-btn
                    icon="mdi-delete"
                    size="small"
                    variant="text"
                    color="error"
                    @click="removeStep(index)"
                  />
                </div>
              </div>
              
              <v-text-field
                v-model="step.title"
                label="タイトル"
                variant="outlined"
                density="compact"
                class="mb-2"
              />
              
              <v-textarea
                v-model="step.description"
                label="説明"
                rows="3"
                variant="outlined"
                density="compact"
              />
              
              <!-- ステップ画像 -->
              <div class="mt-3">
                <v-label class="mb-2">ステップ画像</v-label>
                
                <!-- プレビュー -->
                <v-card v-if="stepImages[index]?.preview || step.image_url" class="mb-2" variant="outlined">
                  <v-img
                    :src="stepImages[index]?.preview || step.image_url"
                    height="150"
                    cover
                  />
                  <v-card-actions>
                    <v-btn
                      variant="text"
                      color="error"
                      size="small"
                      @click="removeStepImage(index)"
                    >
                      画像を削除
                    </v-btn>
                  </v-card-actions>
                </v-card>
                
                <!-- アップロードボタン -->
                <v-file-input
                  v-show="!stepImages[index]?.preview && !step.image_url"
                  accept="image/*"
                  label="画像を選択"
                  variant="outlined"
                  density="compact"
                  prepend-icon="mdi-image"
                  @change="(e: Event) => handleStepImageChange(index, e)"
                />
              </div>
            </div>
          </v-card-text>
        </v-card>

        <!-- アクションボタン -->
        <v-row class="mt-6">
          <v-col class="text-right">
            <v-btn
              variant="text"
              @click="cancel"
              class="mr-2"
            >
              キャンセル
            </v-btn>
            <v-btn
              color="primary"
              type="submit"
              :loading="saving"
            >
              保存
            </v-btn>
          </v-col>
        </v-row>
      </v-form>
    </div>
  </v-container>
</template>

<style scoped>
.border {
  border: 1px solid rgba(0, 0, 0, 0.12);
}
</style>