require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const multer = require('multer');

const upload = multer({ dest: 'uploads/' });
const app = express();
app.use(cors());
app.use(bodyParser.json());

app.get('/health', (req, res) => res.json({status: 'ok', service: 'expense-service'}));

// Submit expense
app.post('/expense', upload.single('receipt'), (req, res) => {
  // req.body: { userId, amount, date, description }
  // req.file: receipt
  res.json({message: 'submit expense (stub)'});
});

const PORT = process.env.PORT || 4003;
app.listen(PORT, () => console.log(`expense-service listening on ${PORT}`));
