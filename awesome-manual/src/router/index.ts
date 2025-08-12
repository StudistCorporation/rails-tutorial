import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '@/views/HomeView.vue'
import ManualListView from '@/views/ManualListView.vue'
import ManualView from '@/views/ManualView.vue'
import ManualEditView from '@/views/ManualEditView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView,
    },
    {
      path: '/manuals',
      name: 'manual-list',
      component: ManualListView,
    },
    {
      path: '/manuals/:id',
      name: 'manual',
      component: ManualView,
    },
    {
      path: '/manuals/:id/edit',
      name: 'manual-edit',
      component: ManualEditView,
    }
  ],
})

export default router
