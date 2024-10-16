<script setup lang="ts">
import { onMounted, ref } from 'vue'

const manuals = ref<Manual[]>([])
</script>

<template>
  <v-container>
    <v-row>
      <v-col v-for="manual in manuals" :key="manual.title" cols="12">
        <v-card @click="$router.push(`/manuals/${manual.id}`)">
          <v-card-title>{{ manual.title }}</v-card-title>
          <v-card-text>{{ manual.description }}</v-card-text>
          <v-card-actions>
            <v-btn>{{ manual.steps.length }} steps</v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>
