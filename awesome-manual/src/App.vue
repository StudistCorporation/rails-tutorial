<script setup lang="ts">
import { useRouter } from 'vue-router'

const router = useRouter()

const goHome = () => {
  router.push('/')
}
</script>

<template>
  <v-app>
    <v-app-bar color="primary" flat>
      <v-app-bar-title class="cursor-pointer" @click="goHome">
        <v-icon class="mr-2">mdi-book-open-variant</v-icon>
        Awesome Manual
      </v-app-bar-title>
      
      <template v-slot:append>
        <v-btn icon="mdi-magnify" />
        <v-btn icon="mdi-plus" />
      </template>
    </v-app-bar>

    <v-main>
      <router-view />
    </v-main>
  </v-app>
</template>

<style scoped>
.cursor-pointer {
  cursor: pointer;
}
</style>
