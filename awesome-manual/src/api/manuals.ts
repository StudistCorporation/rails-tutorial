const API_BASE = '/api/v1'

export interface Tag {
  id: number
  name: string
}

export interface Step {
  id?: number
  title: string
  description: string
  position?: number
  _destroy?: boolean
  image_url?: string
}

export interface Manual {
  id: number
  title: string
  description: string
  tags: Tag[]
  steps: Step[]
  thumbnail_url?: string
  updated_at?: string
}

export interface ManualSummary {
  id: number
  title: string
  description: string
  tags: Tag[]
  updated_at: string
  step_count: number
  thumbnail_url?: string
}

export async function getManuals(): Promise<ManualSummary[]> {
  const response = await fetch(`${API_BASE}/manuals`)
  if (!response.ok) {
    throw new Error('Failed to fetch manuals')
  }
  return response.json()
}

export async function getManual(id: string): Promise<Manual> {
  const response = await fetch(`${API_BASE}/manuals/${id}`)
  if (!response.ok) {
    throw new Error('Failed to fetch manual')
  }
  return response.json()
}

export async function createManual(
  manual: Partial<Manual>, 
  thumbnailFile?: File | null
): Promise<Manual> {
  const hasImages = !!thumbnailFile
  
  if (hasImages) {
    const formData = new FormData()
    formData.append('manual[title]', manual.title || '')
    formData.append('manual[description]', manual.description || '')
    
    // タグ名を配列として送信
    manual.tags?.forEach(tag => {
      formData.append('manual[tag_names][]', tag.name)
    })
    
    // ステップ情報をJSON文字列として送信
    if (manual.steps) {
      formData.append('manual[steps_attributes]', JSON.stringify(manual.steps))
    }
    
    // サムネイル画像
    if (thumbnailFile) {
      formData.append('manual[thumbnail]', thumbnailFile)
    }
    
    const response = await fetch(`${API_BASE}/manuals`, {
      method: 'POST',
      body: formData
    })
    
    if (!response.ok) {
      throw new Error('Failed to create manual')
    }
    
    return response.json()
  } else {
    // 画像がない場合は通常のJSON送信
    const response = await fetch(`${API_BASE}/manuals`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        manual: {
          title: manual.title,
          description: manual.description,
          tag_names: manual.tags?.map(tag => tag.name),
          steps_attributes: manual.steps
        }
      })
    })
    
    if (!response.ok) {
      throw new Error('Failed to create manual')
    }
    
    return response.json()
  }
}

export async function updateManual(
  id: string, 
  manual: Partial<Manual>, 
  thumbnailFile?: File | null,
  stepImages?: Record<number, { file: File | null }>
): Promise<Manual> {
  // FormDataを使って画像も送信
  const hasImages = thumbnailFile || (stepImages && Object.values(stepImages).some(img => img.file))
  
  if (hasImages) {
    const formData = new FormData()
    formData.append('manual[title]', manual.title || '')
    formData.append('manual[description]', manual.description || '')
    
    // タグ名を配列として送信
    manual.tags?.forEach(tag => {
      formData.append('manual[tag_names][]', tag.name)
    })
    
    // ステップ情報をJSON文字列として送信
    if (manual.steps) {
      formData.append('manual[steps_attributes]', JSON.stringify(manual.steps))
    }
    
    // サムネイル画像
    if (thumbnailFile) {
      formData.append('manual[thumbnail]', thumbnailFile)
    }
    
    // ステップ画像
    if (stepImages) {
      manual.steps?.forEach((step, index) => {
        if (step.id && stepImages[index]) {
          const imageData = stepImages[index]
          if (imageData.file) {
            // 新しい画像を添付
            formData.append(`step_images[${step.id}]`, imageData.file)
          } else if (imageData.file === null && imageData.preview === '') {
            // 画像を削除（削除ボタンが押された場合）
            formData.append(`step_images[${step.id}]`, 'null')
          }
        }
      })
    }
    
    const response = await fetch(`${API_BASE}/manuals/${id}`, {
      method: 'PATCH',
      body: formData
    })
    
    if (!response.ok) {
      throw new Error('Failed to update manual')
    }
    
    return response.json()
  } else {
    // 画像がない場合は通常のJSON送信
    const response = await fetch(`${API_BASE}/manuals/${id}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        manual: {
          title: manual.title,
          description: manual.description,
          tag_names: manual.tags?.map(tag => tag.name),
          steps_attributes: manual.steps
        }
      })
    })
    
    if (!response.ok) {
      throw new Error('Failed to update manual')
    }
    
    return response.json()
  }
}
