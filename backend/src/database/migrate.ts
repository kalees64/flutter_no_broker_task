import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import pg from 'pg';
import { env, getDatabaseSslConfig } from '../config/env.js';

const { Client } = pg;
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function ensureDatabaseExists() {
  const sslConfig = getDatabaseSslConfig();
  const rootClient = new Client({
    host: env.DB_HOST,
    port: env.DB_PORT,
    user: env.DB_USER,
    password: env.DB_PASSWORD,
    database: 'postgres',
    ssl: sslConfig,
    connectionTimeoutMillis: 30000,
  });

  try {
    await rootClient.connect();
    const checkRes = await rootClient.query(
      `SELECT 1 FROM pg_database WHERE datname = $1;`,
      [env.DB_NAME]
    );

    if (checkRes.rowCount === 0) {
      console.log(`📦 Database "${env.DB_NAME}" does not exist. Creating...`);
      // Escape database name safely
      await rootClient.query(`CREATE DATABASE "${env.DB_NAME}";`);
      console.log(`✅ Database "${env.DB_NAME}" created successfully.`);
    } else {
      console.log(`🔍 Database "${env.DB_NAME}" verified.`);
    }
  } catch (error: any) {
    console.warn(`⚠️ Notice during root database verification: ${error.message}`);
    console.log(`ℹ️ Attempting direct connection to target database "${env.DB_NAME}"...`);
  } finally {
    try {
      await rootClient.end();
    } catch {}
  }
}

async function runMigrations() {
  await ensureDatabaseExists();

  const sslConfig = getDatabaseSslConfig();
  const client = new Client({
    host: env.DB_HOST,
    port: env.DB_PORT,
    user: env.DB_USER,
    password: env.DB_PASSWORD,
    database: env.DB_NAME,
    ssl: sslConfig,
    connectionTimeoutMillis: 30000,
  });

  try {
    await client.connect();

    // Create schema_migrations table
    await client.query(`
      CREATE TABLE IF NOT EXISTS schema_migrations (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) UNIQUE NOT NULL,
        executed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);

    const migrationsDir = path.resolve(__dirname, '../../migrations');
    if (!fs.existsSync(migrationsDir)) {
      console.log('No migrations directory found.');
      return;
    }

    const files = fs
      .readdirSync(migrationsDir)
      .filter((file) => file.endsWith('.sql'))
      .sort();

    console.log(`🚀 Found ${files.length} migration file(s). Processing...`);

    for (const file of files) {
      const alreadyExecuted = await client.query(
        `SELECT 1 FROM schema_migrations WHERE name = $1;`,
        [file]
      );

      if (alreadyExecuted.rowCount && alreadyExecuted.rowCount > 0) {
        console.log(`⏭️  Migration "${file}" already applied. Skipping.`);
        continue;
      }

      console.log(`▶️  Applying migration: ${file}...`);
      const filePath = path.join(migrationsDir, file);
      const sqlContent = fs.readFileSync(filePath, 'utf-8');

      await client.query('BEGIN');
      try {
        await client.query(sqlContent);
        await client.query(
          `INSERT INTO schema_migrations (name) VALUES ($1);`,
          [file]
        );
        await client.query('COMMIT');
        console.log(`✅ Successfully applied: ${file}`);
      } catch (migrationError) {
        await client.query('ROLLBACK');
        console.error(`❌ Migration failed for "${file}":`, migrationError);
        throw migrationError;
      }
    }

    console.log('🎉 All migrations successfully processed!');
  } catch (err) {
    console.error('Migration runner failed:', err);
    process.exit(1);
  } finally {
    await client.end();
  }
}

runMigrations();
