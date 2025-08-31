import 'dotenv/config';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { Pool } from 'pg';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function main(){
  const connectionString = process.env.DATABASE_URL;
  if(!connectionString){
    console.error('DATABASE_URL is missing in .env');
    process.exit(1);
  }

  const sqlDir = path.resolve(__dirname, '../sql');
  if (!fs.existsSync(sqlDir)){
    console.error('SQL directory not found:', sqlDir);
    process.exit(1);
  }

  // Read all .sql files and sort by filename to ensure order (e.g., 001_, 002_)
  const files = fs.readdirSync(sqlDir)
    .filter(f => f.toLowerCase().endsWith('.sql'))
    .sort((a,b)=> a.localeCompare(b, undefined, { numeric:true }));

  const pool = new Pool({ connectionString, ssl: { rejectUnauthorized: false } });
  try {
    for (const file of files){
      const fullPath = path.join(sqlDir, file);
      const fullSql = fs.readFileSync(fullPath, 'utf8');
      const statements = fullSql
        .split(/;\s*\n|;\s*$/gm)
        .map(s => s.trim())
        .filter(Boolean)
        .map(s => s.endsWith(';') ? s : s + ';');

      for (const stmt of statements){
        await pool.query(stmt);
        console.log(`Ran (${file}):`, stmt.slice(0, 60).replace(/\n/g,' '));
      }
    }
    console.log('✅ Database schema initialized/migrated successfully.');
  } catch (e) {
    console.error('❌ Failed to initialize schema:', e.message);
    process.exitCode = 1;
  } finally {
    await pool.end();
  }
}

main();