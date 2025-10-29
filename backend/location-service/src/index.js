require('dotenv').config();
const express = require('express');
const app = express();
app.use(express.json());
require('./swagger')(app);
app.get('/health', (req, res) => res.json({status: 'ok', service: 'location-service'}));


const db = require('../../common/db');

// Capture location
app.post('/locations', async (req, res) => {
	const { userId, latitude, longitude, description } = req.body;
	if (!userId || !latitude || !longitude) {
		return res.status(400).json({ error: 'Missing required fields' });
	}
	try {
		const { rows } = await db.query(
			'INSERT INTO locations (user_id, latitude, longitude, description) VALUES ($1, $2, $3, $4) RETURNING *',
			[userId, latitude, longitude, description]
		);
		res.status(201).json(rows[0]);
	} catch (err) {
		res.status(500).json({ error: 'DB error', details: err.message });
	}
});

// Get all locations for a user
app.get('/locations/:userId', async (req, res) => {
	try {
		const { rows } = await db.query('SELECT * FROM locations WHERE user_id = $1', [req.params.userId]);
		res.json(rows);
	} catch (err) {
		res.status(500).json({ error: 'DB error', details: err.message });
	}
});

// Get location by ID
app.get('/location/:id', async (req, res) => {
	try {
		const { rows } = await db.query('SELECT * FROM locations WHERE id = $1', [req.params.id]);
		if (!rows[0]) return res.status(404).json({ error: 'Location not found' });
		res.json(rows[0]);
	} catch (err) {
		res.status(500).json({ error: 'DB error', details: err.message });
	}
});
const PORT = process.env.PORT || 4105;
app.listen(PORT, () => console.log(`location-service listening on ${PORT}`));