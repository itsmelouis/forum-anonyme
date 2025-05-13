import express from 'express'
import threadsRouter from './routes/threads.js'
import cors from 'cors'

const app = express()
const PORT = process.env.PORT || 3000

app.use(cors())
app.use(express.json())
app.use('/threads', threadsRouter)

app.get('/', (req, res) => {
  res.send('Forum Anonyme API is running!')
})

app.listen(PORT, () => {
  console.log(`API running on http://localhost:${PORT}`)
})
