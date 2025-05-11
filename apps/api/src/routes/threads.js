import { Router } from 'express'

const router = Router()
const THREAD_SERVICE_URL =
  process.env.THREAD_SERVICE_URL || 'http://thread:4000/threads'

// GET /threads
router.get('/', async (req, res) => {
  try {
    const response = await fetch(THREAD_SERVICE_URL)
    const data = await response.json()
    res.json(data)
  } catch (err) {
    res
      .status(500)
      .json({ error: 'Erreur de communication avec le service thread' })
  }
})

// POST /threads
router.post('/', async (req, res) => {
  const { title, content } = req.body
  if (!title || !content) {
    return res.status(400).json({ error: 'Titre et contenu requis.' })
  }

  try {
    const response = await fetch(THREAD_SERVICE_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ title, content }),
    })
    const data = await response.json()
    res.status(response.status).json(data)
  } catch (err) {
    res.status(500).json({
      error: 'Impossible d’enregistrer le thread via le service thread.',
    })
  }
})

export default router
