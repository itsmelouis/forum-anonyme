<template>
  <div class="sender-container">
    <div class="card-container">
      <div class="header">
        <h1>Forum Anonyme</h1>
        <p class="subtitle">Partagez vos pensées en toute liberté</p>
      </div>
      
      <form @submit.prevent="sendMessage" class="message-form">
        <div class="form-group">
          <label for="title">Titre</label>
          <input 
            id="title" 
            v-model="title" 
            placeholder="Donnez un titre à votre message" 
            required 
          />
        </div>

        <div class="form-group">
          <label for="content">Message</label>
          <textarea 
            id="content" 
            v-model="content" 
            placeholder="Exprimez-vous librement..." 
            rows="6" 
            required
          ></textarea>
        </div>

        <button type="submit" class="submit-btn" :disabled="sending">
          <span v-if="!sending">Envoyer</span>
          <span v-else>Envoi en cours...</span>
        </button>
      </form>
      
      <div class="notification-area">
        <div v-if="message" class="notification success">
          <span class="icon">✓</span> {{ message }}
        </div>
        <div v-if="error" class="notification error">
          <span class="icon">✗</span> {{ error }}
        </div>
      </div>
      
      <div class="footer">
        <p>Tous les messages sont anonymes et publics</p>
      </div>
    </div>
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
      sending: false
    }
  },
  methods: {
    async sendMessage() {
      this.sending = true;
      this.message = '';
      this.error = '';
      
      try {
        const res = await fetch('http://localhost:3000/threads', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            title: this.title,
            content: this.content,
          }),
        })

        if (!res.ok) {
          const errorData = await res.json();
          throw new Error(errorData.error || 'Erreur lors de l\'envoi');
        }

        this.message = 'Message envoyé avec succès !'
        this.title = ''
        this.content = ''
      } catch (e) {
        this.error = e.message
      } finally {
        this.sending = false;
      }
    },
  },
}
</script>

<style scoped>
.sender-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  padding: 2rem;
}

.card-container {
  background-color: #ffffff;
  border-radius: 12px;
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.12);
  width: 100%;
  max-width: 600px;
  overflow: hidden;
}

.header {
  padding: 2rem 2rem 1rem;
  text-align: center;
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

.message-form {
  padding: 1rem 2rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 600;
  color: #444;
  font-size: 0.95rem;
}

input, textarea {
  width: 100%;
  padding: 0.8rem 1rem;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 1rem;
  transition: border-color 0.3s, box-shadow 0.3s;
  background-color: #f9f9f9;
}

input:focus, textarea:focus {
  outline: none;
  border-color: #646cff;
  box-shadow: 0 0 0 3px rgba(100, 108, 255, 0.2);
}

.submit-btn {
  width: 100%;
  padding: 0.9rem;
  background-color: #646cff;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.3s, transform 0.2s;
}

.submit-btn:hover {
  background-color: #535bf2;
  transform: translateY(-2px);
}

.submit-btn:disabled {
  background-color: #a5a9f3;
  cursor: not-allowed;
  transform: none;
}

.notification-area {
  padding: 0 2rem 1rem;
}

.notification {
  padding: 0.8rem 1rem;
  border-radius: 8px;
  margin-top: 1rem;
  display: flex;
  align-items: center;
  font-size: 0.95rem;
}

.notification.success {
  background-color: rgba(46, 213, 115, 0.15);
  color: #2ed573;
  border-left: 4px solid #2ed573;
}

.notification.error {
  background-color: rgba(255, 71, 87, 0.15);
  color: #ff4757;
  border-left: 4px solid #ff4757;
}

.notification .icon {
  margin-right: 0.8rem;
  font-weight: bold;
}

.footer {
  padding: 1rem 2rem 2rem;
  text-align: center;
  color: #888;
  font-size: 0.85rem;
  border-top: 1px solid #eee;
  margin-top: 1rem;
}

@media (max-width: 640px) {
  .sender-container {
    padding: 1rem;
  }
  
  .card-container {
    border-radius: 8px;
  }
  
  .header {
    padding: 1.5rem 1.5rem 0.5rem;
  }
  
  .header h1 {
    font-size: 1.8rem;
  }
  
  .message-form,
  .notification-area {
    padding: 1rem 1.5rem;
  }
}
</style>
