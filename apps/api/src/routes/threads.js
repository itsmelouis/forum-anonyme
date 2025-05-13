import { Router } from 'express'
import { getAllThreads, createThread } from '../db.js'

const router = Router()

router.get('/', async (req, res) => {
  try {
    const threads = await getAllThreads()
    res.json(threads)
  } catch (err) {
    console.error(err)
    res
      .status(500)
      .json({ error: 'Erreur lors de la récupération des messages' })
  }
})

router.post('/', async (req, res) => {
  const { title, content } = req.body
  if (!title || !content) {
    return res.status(400).json({ error: 'Titre et contenu requis.' })
  }

  try {
    const thread = await createThread({ title, content })
    res.status(201).json(thread)
  } catch (err) {
    console.error(err)
    res
      .status(500)
      .json({ error: 'Erreur lors de l’enregistrement du message' })
  }
})

export default router
