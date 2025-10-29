require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');


const app = express();
app.use(cors());
app.use(bodyParser.json());

// Swagger UI integration
require('./swagger')(app);

app.get('/health', (req, res) => res.json({status: 'ok', service: 'timesheet-service'}));



const db = require('../../common/db');

// Capture start/end time (clock in/out)
app.post('/timesheet/clock', async (req, res) => {
  const { userId, type, timestamp, location } = req.body;
  if (!userId || !type || !timestamp) {
    return res.status(400).json({ error: 'Missing required fields' });
  }
  try {
    const { rows } = await db.query(
      'INSERT INTO timesheet_entries (user_id, type, timestamp, location) VALUES ($1, $2, $3, $4) RETURNING *',
      [userId, type, timestamp, location]
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'DB error', details: err.message });
  }
});

// Get all clock entries for a user
app.get('/timesheet/clock/:userId', async (req, res) => {
  try {
    const { rows } = await db.query('SELECT * FROM timesheet_entries WHERE user_id = $1', [req.params.userId]);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: 'DB error', details: err.message });
  }
});

// Book/submit timesheet
app.post('/timesheet/book', async (req, res) => {
  const { userId, entries } = req.body;
  if (!userId || !Array.isArray(entries)) {
    return res.status(400).json({ error: 'Missing required fields' });
  }
  try {
    const { rows } = await db.query(
      'INSERT INTO timesheets (user_id) VALUES ($1) RETURNING *',
      [userId]
    );
    const timesheet = rows[0];
    // Link entries to timesheet
    for (const entryId of entries) {
      await db.query('INSERT INTO timesheet_entry_map (timesheet_id, entry_id) VALUES ($1, $2)', [timesheet.id, entryId]);
    }
    res.status(201).json(timesheet);
  } catch (err) {
    res.status(500).json({ error: 'DB error', details: err.message });
  }
});

// Get all timesheets for a user
app.get('/timesheet/:userId', async (req, res) => {
  try {
    const { rows } = await db.query('SELECT * FROM timesheets WHERE user_id = $1', [req.params.userId]);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: 'DB error', details: err.message });
  }
});

// Get timesheet by ID
app.get('/timesheet/id/:id', async (req, res) => {
  try {
    const { rows } = await db.query('SELECT * FROM timesheets WHERE id = $1', [req.params.id]);
    if (!rows[0]) return res.status(404).json({ error: 'Timesheet not found' });
    // Get linked entries
    const { rows: entryRows } = await db.query(
      'SELECT e.* FROM timesheet_entries e JOIN timesheet_entry_map m ON e.id = m.entry_id WHERE m.timesheet_id = $1',
      [req.params.id]
    );
    res.json({ ...rows[0], entries: entryRows });
  } catch (err) {
    res.status(500).json({ error: 'DB error', details: err.message });
  }
});

// Capture start/end time (clock in/out)
app.post('/timesheet/clock', (req, res) => {
  const { userId, type, timestamp, location } = req.body;
  if (!userId || !type || !timestamp) {
    return res.status(400).json({ error: 'Missing required fields' });
  }
  const id = timesheetEntries.length + 1;
  const entry = { id, userId, type, timestamp, location };
  timesheetEntries.push(entry);
  res.status(201).json(entry);
});

// Get all clock entries for a user
app.get('/timesheet/clock/:userId', (req, res) => {
  const userEntries = timesheetEntries.filter(e => e.userId == req.params.userId);
  res.json(userEntries);
});

// Book/submit timesheet
app.post('/timesheet/book', (req, res) => {
  const { userId, entries } = req.body;
  if (!userId || !Array.isArray(entries)) {
    return res.status(400).json({ error: 'Missing required fields' });
  }
  const id = timesheets.length + 1;
  const timesheet = { id, userId, entries, submittedAt: new Date(), status: 'pending' };
  timesheets.push(timesheet);
  res.status(201).json(timesheet);
});

// Get all timesheets for a user
app.get('/timesheet/:userId', (req, res) => {
  const userSheets = timesheets.filter(t => t.userId == req.params.userId);
  res.json(userSheets);
});

// Get timesheet by ID
app.get('/timesheet/id/:id', (req, res) => {
  const timesheet = timesheets.find(t => t.id == req.params.id);
  if (!timesheet) return res.status(404).json({ error: 'Timesheet not found' });
  res.json(timesheet);
});

const PORT = process.env.PORT || 4002;
app.listen(PORT, () => console.log(`timesheet-service listening on ${PORT}`));
