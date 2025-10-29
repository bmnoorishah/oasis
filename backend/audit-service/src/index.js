require('dotenv').config();
const express = require('express');
const app = express();
app.use(express.json());
require('./swagger')(app);
app.get('/health', (req, res) => res.json({status: 'ok', service: 'audit-service'}));


const db = require('../../common/db');

// Log an action
app.post('/audit', async (req, res) => {
	const { userId, action, details } = req.body;
	if (!userId || !action) {
		return res.status(400).json({ error: 'Missing required fields' });
	}
	try {
		const { rows } = await db.query(
			'INSERT INTO audit_logs (user_id, action, details) VALUES ($1, $2, $3) RETURNING *',
			[userId, action, details]
		);
		res.status(201).json(rows[0]);
	} catch (err) {
		res.status(500).json({ error: 'DB error', details: err.message });
	}
});

// Get all audit logs for a user
app.get('/audit/:userId', async (req, res) => {
	try {
		const { rows } = await db.query('SELECT * FROM audit_logs WHERE user_id = $1', [req.params.userId]);
		res.json(rows);
	} catch (err) {
		res.status(500).json({ error: 'DB error', details: err.message });
	}
});

// Get audit log by ID
app.get('/audit/id/:id', async (req, res) => {
	try {
		const { rows } = await db.query('SELECT * FROM audit_logs WHERE id = $1', [req.params.id]);
		if (!rows[0]) return res.status(404).json({ error: 'Audit log not found' });
		res.json(rows[0]);
	} catch (err) {
		res.status(500).json({ error: 'DB error', details: err.message });
	}
});
const PORT = process.env.PORT || 4107;
app.listen(PORT, () => console.log(`audit-service listening on ${PORT}`));