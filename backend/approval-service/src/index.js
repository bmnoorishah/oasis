require('dotenv').config();
const express = require('express');
const app = express();
app.use(express.json());
require('./swagger')(app);
app.get('/health', (req, res) => res.json({status: 'ok', service: 'approval-service'}));


const db = require('../../common/db');

// Get all approvals
app.get('/approvals', async (req, res) => {
	try {
		const { rows } = await db.query('SELECT * FROM approvals');
		res.json(rows);
	} catch (err) {
		res.status(500).json({ error: 'DB error', details: err.message });
	}
});

// Approve/reject a timesheet
app.post('/approvals', async (req, res) => {
	const { timesheetId, approverId, status, comment } = req.body;
	if (!timesheetId || !approverId || !status) {
		return res.status(400).json({ error: 'Missing required fields' });
	}
	try {
		const { rows } = await db.query(
			'INSERT INTO approvals (timesheet_id, approver_id, status, comment) VALUES ($1, $2, $3, $4) RETURNING *',
			[timesheetId, approverId, status, comment]
		);
		res.status(201).json(rows[0]);
	} catch (err) {
		res.status(500).json({ error: 'DB error', details: err.message });
	}
});

// Get approval by ID
app.get('/approvals/:id', async (req, res) => {
	try {
		const { rows } = await db.query('SELECT * FROM approvals WHERE id = $1', [req.params.id]);
		if (!rows[0]) return res.status(404).json({ error: 'Approval not found' });
		res.json(rows[0]);
	} catch (err) {
		res.status(500).json({ error: 'DB error', details: err.message });
	}
});
const PORT = process.env.PORT || 4103;
app.listen(PORT, () => console.log(`approval-service listening on ${PORT}`));