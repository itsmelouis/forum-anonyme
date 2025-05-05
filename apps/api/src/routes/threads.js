import { Router } from 'express'

const router = Router()

// Liste des threads (mock)
router.get('/', (req, res) => {
  res.json([
    { id: 1, title: 'Premier thread', content: 'Hello world' },
    { id: 2, title: 'Deuxième thread', content: 'Contenu anonyme' },
  ])
})

// Création d’un thread
router.post('/', (req, res) => {
  const { title, content } = req.body
  if (!title || !content) {
    return res.status(400).json({ error: 'Titre et contenu requis.' })
  }
  // Simulation d’enregistrement
  const newThread = {
    id: Date.now(),
    title,
    content,
  }
  res.status(201).json(newThread)
})

export default router
