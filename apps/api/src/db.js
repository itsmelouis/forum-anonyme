import pkg from 'pg'
const { Pool } = pkg

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
})

export async function getAllThreads() {
  const result = await pool.query(
    'SELECT * FROM threads ORDER BY created_at DESC'
  )
  return result.rows
}

export async function createThread({ title, content }) {
  const result = await pool.query(
    'INSERT INTO threads (title, content) VALUES ($1, $2) RETURNING *',
    [title, content]
  )
  return result.rows[0]
}
