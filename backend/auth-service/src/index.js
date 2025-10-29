require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');


const app = express();
app.use(cors());
app.use(bodyParser.json());

// Swagger UI integration
require('./swagger')(app);

app.get('/health', (req, res) => res.json({status: 'ok', service: 'auth-service'}));


const db = require('../../common/db');

// Issue token (login)
app.post('/login', async (req, res) => {
  const { userId } = req.body;
  if (!userId) {
    return res.status(400).json({ error: 'Missing userId' });
  }
  const token = `token-${userId}-${Date.now()}`;
  const issuedAt = new Date();
  const expiresAt = new Date(Date.now() + 3600 * 1000); // 1 hour expiry
  try {
    await db.query(
      'INSERT INTO auth_tokens (token, user_id, issued_at, expires_at) VALUES ($1, $2, $3, $4)',
      [token, userId, issuedAt, expiresAt]
    );
    res.json({ token, issuedAt, expiresAt });
  } catch (err) {
    res.status(500).json({ error: 'DB error', details: err.message });
  }
});

// Validate token
app.post('/validate', async (req, res) => {
  const { token } = req.body;
  try {
    const { rows } = await db.query(
      'SELECT * FROM auth_tokens WHERE token = $1 AND expires_at > NOW()',
      [token]
    );
    if (!rows[0]) return res.status(401).json({ error: 'Invalid or expired token' });
    res.json({ valid: true, userId: rows[0].user_id });
  } catch (err) {
    res.status(500).json({ error: 'DB error', details: err.message });
  }
});

// Logout (invalidate token)
app.post('/logout', async (req, res) => {
  const { token } = req.body;
  try {
    const { rowCount } = await db.query('DELETE FROM auth_tokens WHERE token = $1', [token]);
    if (rowCount === 0) return res.status(404).json({ error: 'Token not found' });
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: 'DB error', details: err.message });
  }
});

const PORT = process.env.PORT || 4001;
app.listen(PORT, () => console.log(`auth-service listening on ${PORT}`));
