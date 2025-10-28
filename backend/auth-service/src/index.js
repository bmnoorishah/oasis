require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(bodyParser.json());

app.get('/health', (req, res) => res.json({status: 'ok', service: 'auth-service'}));

// Placeholder auth endpoints
app.post('/login', (req, res) => {
  // Validate credentials, issue JWT
  res.json({message: 'login endpoint (stub)'});
});

app.post('/logout', (req, res) => {
  res.json({message: 'logout endpoint (stub)'});
});

const PORT = process.env.PORT || 4001;
app.listen(PORT, () => console.log(`auth-service listening on ${PORT}`));
