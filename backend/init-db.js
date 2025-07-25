import { Pool } from 'pg';
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import path from 'path';
import dotenv from 'dotenv';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

async function initializeDatabase() {
  const client = await pool.connect();
  try {
    // Read the SQL file
    const sql = readFileSync(path.join(__dirname, 'db_init.sql'), 'utf8');
    
    // Start a transaction
    await client.query('BEGIN');
    
    // Split the SQL file into individual statements and execute them
    const statements = sql
      .split(';')
      .map(statement => statement.trim())
      .filter(statement => statement.length > 0);
    
    for (const statement of statements) {
      if (statement) {
        await client.query(statement);
      }
    }
    
    await client.query('COMMIT');
    console.log('Database initialized successfully');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Error initializing database:', err);
    throw err;
  } finally {
    client.release();
    await pool.end();
  }
}

initializeDatabase()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('Failed to initialize database:', err);
    process.exit(1);
  });
