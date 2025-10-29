require('dotenv').config();
const express = require('express');
const cors = require('cors');
const app = express();
app.use(cors());
app.use(express.json());
require('./swagger')(app);
app.get('/health', (req, res) => res.json({status: 'ok', service: 'user-service'}));


const db = require('../../common/db');

// Get all users
app.get('/users', async (req, res) => {
	try {
		const { rows } = await db.query('SELECT * FROM users');
		res.json(rows);
	} catch (err) {
		res.status(500).json({ error: 'DB error', details: err.message });
	}
});

// Create user
app.post('/users', async (req, res) => {
	const { name, email, password, role } = req.body;
	if (!name || !email || !password || !role) {
		return res.status(400).json({ error: 'Missing required fields' });
	}
	const passwordHash = `hashed_${password}`; // Replace with real hash
	try {
		const { rows } = await db.query(
			'INSERT INTO users (name, email, password_hash, role) VALUES ($1, $2, $3, $4) RETURNING *',
			[name, email, passwordHash, role]
		);
		res.status(201).json(rows[0]);
	} catch (err) {
		res.status(500).json({ error: 'DB error', details: err.message });
	}
});

// Get user by ID
app.get('/users/:id', async (req, res) => {
	try {
		const { rows } = await db.query('SELECT * FROM users WHERE id = $1', [req.params.id]);
		if (!rows[0]) return res.status(404).json({ error: 'User not found' });
		res.json(rows[0]);
	} catch (err) {
		res.status(500).json({ error: 'DB error', details: err.message });
	}
});

// Update user
app.put('/users/:id', async (req, res) => {
	const { name, email, password, role } = req.body;
	try {
		const { rows } = await db.query(
			'UPDATE users SET name = COALESCE($1, name), email = COALESCE($2, email), password_hash = COALESCE($3, password_hash), role = COALESCE($4, role) WHERE id = $5 RETURNING *',
			[name, email, password ? `hashed_${password}` : null, role, req.params.id]
		);
		if (!rows[0]) return res.status(404).json({ error: 'User not found' });
		res.json(rows[0]);
	} catch (err) {
		res.status(500).json({ error: 'DB error', details: err.message });
	}
});

// Delete user
app.delete('/users/:id', async (req, res) => {
	try {
		const { rowCount } = await db.query('DELETE FROM users WHERE id = $1', [req.params.id]);
		if (rowCount === 0) return res.status(404).json({ error: 'User not found' });
		res.json({ success: true });
	} catch (err) {
		res.status(500).json({ error: 'DB error', details: err.message });
	}
});

// List roles (from DB)
app.get('/roles', async (req, res) => {
	try {
		const { rows } = await db.query('SELECT * FROM roles');
		res.json(rows);
	} catch (err) {
		res.status(500).json({ error: 'DB error', details: err.message });
	}
});

// Get all users
app.get('/users', (req, res) => {
	res.json(users);
});

// Create user
app.post('/users', (req, res) => {
	const { name, email, password, role } = req.body;
	if (!name || !email || !password || !role) {
		return res.status(400).json({ error: 'Missing required fields' });
	}
	const id = users.length + 1;
	const passwordHash = `hashed_${password}`; // Replace with real hash
	const user = { id, name, email, passwordHash, role, createdAt: new Date() };
	users.push(user);
	res.status(201).json(user);
});

// Get user by ID
app.get('/users/:id', (req, res) => {
	const user = users.find(u => u.id == req.params.id);
	if (!user) return res.status(404).json({ error: 'User not found' });
	res.json(user);
});

// Update user
app.put('/users/:id', (req, res) => {
	const user = users.find(u => u.id == req.params.id);
	if (!user) return res.status(404).json({ error: 'User not found' });
	Object.assign(user, req.body);
	res.json(user);
});

// Delete user
app.delete('/users/:id', (req, res) => {
	const idx = users.findIndex(u => u.id == req.params.id);
	if (idx === -1) return res.status(404).json({ error: 'User not found' });
	users.splice(idx, 1);
	res.json({ success: true });
});

// List roles
app.get('/roles', (req, res) => {
	res.json(roles);
});

// Simple login endpoint (demo only)
app.post('/login', (req, res) => {
	const { email, password } = req.body;
	const user = users.find(u => u.email === email && u.passwordHash === `hashed_${password}`);
	if (!user) return res.status(401).json({ error: 'Invalid credentials' });
	// Return a fake token for demo
	res.json({ token: `token-for-user-${user.id}`, user });
});
const PORT = process.env.PORT || 4101;
app.listen(PORT, () => console.log(`user-service listening on ${PORT}`));