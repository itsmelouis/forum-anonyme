<template>
  <div class="thread-container">
    <div class="card-container">
      <div class="header">
        <h1>Forum Anonyme</h1>
        <p class="subtitle">Discussions anonymes en temps réel</p>
      </div>

      <div class="controls">
        <button @click="loadThreads" class="reload-btn" :disabled="loading">
          <span v-if="!loading" class="reload-icon">&#8635;</span>
          <span v-else class="loading-icon">&#8987;</span>
          <span>{{ loading ? 'Chargement...' : 'Actualiser' }}</span>
        </button>
        <p v-if="lastUpdated" class="last-updated">
          Dernière mise à jour: {{ lastUpdated }}
        </p>
      </div>

      <div class="messages-container" v-if="threads.length > 0">
        <div v-for="thread in threads" :key="thread.id" class="message-card">
          <div class="message-header">
            <h3 class="message-title">{{ thread.title }}</h3>
            <span class="message-date">{{
              formatDate(thread.created_at)
            }}</span>
          </div>
          <p class="message-content">{{ thread.content }}</p>
        </div>
      </div>

      <div v-else-if="!loading" class="empty-state">
        <p>Aucun message pour le moment</p>
        <p class="empty-hint">Soyez le premier à poster un message!</p>
      </div>

      <div v-if="loading && threads.length === 0" class="loading-state">
        <div class="loading-spinner"></div>
        <p>Chargement des messages...</p>
      </div>

      <div class="footer">
        <p>
          Vous pouvez envoyer un message anonyme sur
          <a href="http://localhost:8080" target="_blank">la page d'envoi</a>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const threads = ref([])
const loading = ref(false)
const lastUpdated = ref('')

const formatDate = (dateString) => {
  if (!dateString) return ''

  const date = new Date(dateString)
  return new Intl.DateTimeFormat('fr-FR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  }).format(date)
}

const updateLastUpdated = () => {
  const now = new Date()
  lastUpdated.value = new Intl.DateTimeFormat('fr-FR', {
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
  }).format(now)
}

const loadThreads = async () => {
  loading.value = true

  try {
    const res = await fetch('http://localhost:3000/threads')
    if (!res.ok) {
      throw new Error('Erreur lors du chargement des messages')
    }

    threads.value = await res.json()
    updateLastUpdated()
  } catch (error) {
    console.error('Erreur:', error)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadThreads()
})
</script>

<style scoped>
.thread-container {
  display: flex;
  justify-content: center;
  align-items: flex-start;
  min-height: 100vh;
  padding: 2rem;
}

.card-container {
  background-color: #ffffff;
  border-radius: 12px;
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.12);
  width: 100%;
  max-width: 800px;
  overflow: hidden;
}

.header {
  padding: 2rem 2rem 1rem;
  text-align: center;
  border-bottom: 1px solid #f0f0f0;
}

.header h1 {
  margin: 0;
  color: #333;
  font-size: 2.2rem;
  font-weight: 700;
}

.subtitle {
  color: #666;
  margin-top: 0.5rem;
  font-size: 1.1rem;
}

.controls {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 2rem;
  background-color: #f9f9f9;
  border-bottom: 1px solid #f0f0f0;
}

.reload-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background-color: #646cff;
  color: white;
  border: none;
  border-radius: 8px;
  padding: 0.6rem 1.2rem;
  font-weight: 600;
  cursor: pointer;
  transition:
    background-color 0.3s,
    transform 0.2s;
}

.reload-btn:hover {
  background-color: #535bf2;
  transform: translateY(-2px);
}

.reload-btn:disabled {
  background-color: #a5a9f3;
  cursor: not-allowed;
  transform: none;
}

.reload-icon {
  font-size: 1.2rem;
  display: inline-block;
}

.loading-icon {
  display: inline-block;
  animation: spin 1.5s linear infinite;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

.last-updated {
  font-size: 0.85rem;
  color: #888;
  margin: 0;
}

.messages-container {
  padding: 1.5rem 2rem;
  max-height: 60vh;
  overflow-y: auto;
}

.message-card {
  background-color: #f9f9f9;
  border-radius: 8px;
  padding: 1.2rem;
  margin-bottom: 1rem;
  border-left: 4px solid #646cff;
  transition:
    transform 0.2s,
    box-shadow 0.2s;
}

.message-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.message-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 0.8rem;
}

.message-title {
  margin: 0;
  font-size: 1.2rem;
  color: #333;
  font-weight: 600;
}

.message-date {
  font-size: 0.8rem;
  color: #888;
}

.message-content {
  margin: 0;
  color: #444;
  line-height: 1.5;
  white-space: pre-line;
}

.empty-state,
.loading-state {
  padding: 3rem 2rem;
  text-align: center;
  color: #666;
}

.empty-hint {
  font-size: 0.9rem;
  color: #888;
  margin-top: 0.5rem;
}

.loading-spinner {
  display: inline-block;
  width: 40px;
  height: 40px;
  border: 3px solid rgba(100, 108, 255, 0.3);
  border-radius: 50%;
  border-top-color: #646cff;
  animation: spin 1s ease-in-out infinite;
  margin-bottom: 1rem;
}

.footer {
  padding: 1.5rem 2rem;
  text-align: center;
  color: #888;
  font-size: 0.9rem;
  border-top: 1px solid #f0f0f0;
}

@media (max-width: 768px) {
  .thread-container {
    padding: 1rem;
  }

  .card-container {
    border-radius: 8px;
  }

  .header {
    padding: 1.5rem 1.5rem 1rem;
  }

  .header h1 {
    font-size: 1.8rem;
  }

  .controls {
    flex-direction: column;
    gap: 0.8rem;
    align-items: flex-start;
  }

  .reload-btn {
    width: 100%;
    justify-content: center;
  }

  .messages-container {
    padding: 1rem 1.5rem;
  }
}
</style>
