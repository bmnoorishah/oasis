require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const multer = require('multer');

const upload = multer({ dest: 'uploads/' });
const app = express();
app.use(cors());
app.use(bodyParser.json());

app.get('/health', (req, res) => res.json({status: 'ok', service: 'document-service'}));

// Submit document
app.post('/documents', upload.single('file'), (req, res) => {
  res.json({message: 'submit document (stub)'});
});

const PORT = process.env.PORT || 4004;
app.listen(PORT, () => console.log(`document-service listening on ${PORT}`));
