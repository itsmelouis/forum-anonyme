<template>
  <div>
    <h1>Envoyer un message anonyme</h1>
    <form @submit.prevent="sendMessage">
      <label>Titre :</label>
      <input v-model="title" required /><br />

      <label>Contenu :</label>
      <textarea v-model="content" required></textarea><br />

      <button type="submit">Envoyer</button>
    </form>
    <p v-if="message" style="color: green">{{ message }}</p>
    <p v-if="error" style="color: red">{{ error }}</p>
  </div>
</template>

<script>
export default {
  data() {
    return {
      title: '',
      content: '',
      message: '',
      error: '',
    }
  },
  methods: {
    async sendMessage() {
      try {
        const res = await fetch('http://localhost:3000/threads', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            title: this.title,
            content: this.content,
          }),
        })

        if (!res.ok) throw new Error('Erreur lors de l’envoi')

        this.message = 'Message envoyé avec succès !'
        this.error = ''
        this.title = ''
        this.content = ''
      } catch (e) {
        this.error = e.message
        this.message = ''
      }
    },
  },
}
</script>
