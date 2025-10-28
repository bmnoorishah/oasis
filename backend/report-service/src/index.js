require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(bodyParser.json());

app.get('/health', (req, res) => res.json({status: 'ok', service: 'report-service'}));

// Generate basic reports
app.get('/reports/timesheets', (req, res) => {
  // implement aggregation
  res.json({message: 'timesheet report (stub)'});
});

const PORT = process.env.PORT || 4005;
app.listen(PORT, () => console.log(`report-service listening on ${PORT}`));
