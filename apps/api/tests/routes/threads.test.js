import { describe, it, expect } from '@jest/globals'
import request from 'supertest'
import express from 'express'
import cors from 'cors'
import threadsRouter from '../../src/routes/threads.js'

// Configurer l'application Express pour les tests
const app = express()
app.use(cors())
app.use(express.json())
app.use('/threads', threadsRouter)

describe('Threads API Routes', () => {
  // Tests simples pour la validation des entrées
  describe('POST /threads validation', () => {
    it('should return 400 when title is missing', async () => {
      const response = await request(app)
        .post('/threads')
        .send({ content: 'Content Only' })

      expect(response.status).toBe(400)
      expect(response.body).toHaveProperty('error')
    })

    it('should return 400 when content is missing', async () => {
      const response = await request(app)
        .post('/threads')
        .send({ title: 'Title Only' })

      expect(response.status).toBe(400)
      expect(response.body).toHaveProperty('error')
    })
  })

  // Tests de structure de l'API
  describe('API Structure', () => {
    it('should have the correct routes defined', () => {
      // Vérifier que le routeur a les bonnes méthodes définies
      const routes = threadsRouter.stack.map((layer) => {
        return {
          path: layer.route?.path,
          methods: layer.route ? Object.keys(layer.route.methods) : [],
        }
      })

      // Vérifier qu'il y a au moins une route GET et une route POST
      const hasGetRoute = routes.some(
        (route) => route.path === '/' && route.methods.includes('get')
      )
      const hasPostRoute = routes.some(
        (route) => route.path === '/' && route.methods.includes('post')
      )

      expect(hasGetRoute).toBe(true)
      expect(hasPostRoute).toBe(true)
    })
  })

  // Tests de structure des réponses
  describe('Response Structure', () => {
    it('should return proper error structure for validation errors', async () => {
      const response = await request(app).post('/threads').send({})

      expect(response.status).toBe(400)
      expect(response.body).toHaveProperty('error')
      expect(typeof response.body.error).toBe('string')
    })
  })
})
