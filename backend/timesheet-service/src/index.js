require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(bodyParser.json());

app.get('/health', (req, res) => res.json({status: 'ok', service: 'timesheet-service'}));

// Capture start/end time
app.post('/timesheet/clock', (req, res) => {
  // req.body: { userId, action: 'start'|'end', timestamp }
  res.json({message: 'clock endpoint (stub)'});
});

// Book timesheet
app.post('/timesheet/book', (req, res) => {
  res.json({message: 'book timesheet (stub)'});
});

const PORT = process.env.PORT || 4002;
app.listen(PORT, () => console.log(`timesheet-service listening on ${PORT}`));
