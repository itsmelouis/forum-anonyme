<template>
  <div>
    <h1>Messages du forum</h1>
    <ul>
      <li v-for="thread in threads" :key="thread.id">
        <strong>{{ thread.title }}</strong
        ><br />
        {{ thread.content }}
      </li>
    </ul>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const threads = ref([])
onMounted(async () => {
  const res = await fetch('http://localhost:3000/threads')
  threads.value = await res.json()
})
</script>
