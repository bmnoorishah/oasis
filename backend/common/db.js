const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://oasis:xjUzJhZAWw87YXwpzhwbGBAuOOEY4YQE@dpg-d405r2jipnbc73ce47e0-a.oregon-postgres.render.com/oasis_jrum',
  ssl: { rejectUnauthorized: false }
});

module.exports = pool;
