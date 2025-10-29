require('dotenv').config();
const express = require('express');
const app = express();
app.use(express.json());
require('./swagger')(app);
app.get('/health', (req, res) => res.json({status: 'ok', service: 'device-service'}));


const db = require('../../common/db');

// Register device
app.post('/devices', async (req, res) => {
	const { userId, type, os, metadata } = req.body;
	if (!userId || !type || !os) {
		return res.status(400).json({ error: 'Missing required fields' });
	}
	try {
		const { rows } = await db.query(
			'INSERT INTO devices (user_id, type, os, metadata) VALUES ($1, $2, $3, $4) RETURNING *',
			[userId, type, os, metadata]
		);
		res.status(201).json(rows[0]);
	} catch (err) {
		res.status(500).json({ error: 'DB error', details: err.message });
	}
});

// Get all devices for a user
app.get('/devices/:userId', async (req, res) => {
	try {
		const { rows } = await db.query('SELECT * FROM devices WHERE user_id = $1', [req.params.userId]);
		res.json(rows);
	} catch (err) {
		res.status(500).json({ error: 'DB error', details: err.message });
	}
});

// Get device by ID
app.get('/device/:id', async (req, res) => {
	try {
		const { rows } = await db.query('SELECT * FROM devices WHERE id = $1', [req.params.id]);
		if (!rows[0]) return res.status(404).json({ error: 'Device not found' });
		res.json(rows[0]);
	} catch (err) {
		res.status(500).json({ error: 'DB error', details: err.message });
	}
});
const PORT = process.env.PORT || 4104;
app.listen(PORT, () => console.log(`device-service listening on ${PORT}`));