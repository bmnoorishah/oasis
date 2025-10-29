require('dotenv').config();
const express = require('express');
const app = express();
app.use(express.json());
require('./swagger')(app);
app.get('/health', (req, res) => res.json({status: 'ok', service: 'notification-service'}));


const db = require('../../common/db');

// Send notification
app.post('/notifications', async (req, res) => {
	const { userId, message, type } = req.body;
	if (!userId || !message || !type) {
		return res.status(400).json({ error: 'Missing required fields' });
	}
	try {
		const { rows } = await db.query(
			'INSERT INTO notifications (user_id, message, type) VALUES ($1, $2, $3) RETURNING *',
			[userId, message, type]
		);
		res.status(201).json(rows[0]);
	} catch (err) {
		res.status(500).json({ error: 'DB error', details: err.message });
	}
});

// Get all notifications for a user
app.get('/notifications/:userId', async (req, res) => {
	try {
		const { rows } = await db.query('SELECT * FROM notifications WHERE user_id = $1', [req.params.userId]);
		res.json(rows);
	} catch (err) {
		res.status(500).json({ error: 'DB error', details: err.message });
	}
});

// Mark notification as read
app.put('/notification/:id/read', async (req, res) => {
	try {
		const { rows } = await db.query('UPDATE notifications SET read = TRUE WHERE id = $1 RETURNING *', [req.params.id]);
		if (!rows[0]) return res.status(404).json({ error: 'Notification not found' });
		res.json(rows[0]);
	} catch (err) {
		res.status(500).json({ error: 'DB error', details: err.message });
	}
});
const PORT = process.env.PORT || 4106;
app.listen(PORT, () => console.log(`notification-service listening on ${PORT}`));