<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'

const manual = ref<Manual | null>(null)
const route = useRoute()

onMounted(() => {
  const { id } = route.params
})
</script>

<template>
  <v-container>
    <div v-if="!manual">Loading...</div>
    <div v-if="manual">
      <h1>{{ manual.title }}</h1>
      <p>{{ manual.description }}</p>
      <v-row :style="{ marginTop: '20px' }">
        <v-col
          v-for="(step, index) in manual.steps"
          :key="step.title"
          cols="12"
        >
          <v-card>
            <v-card-title>STEP-{{ index + 1 }}: {{ step.title }}</v-card-title>
            <v-card-text>{{ step.description }}</v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </div>
  </v-container>
</template>
