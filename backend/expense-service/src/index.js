require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const { generateMockExpenses } = require('./mockData');

const upload = multer({ 
  dest: 'uploads/',
  fileFilter: (req, file, cb) => {
    // Accept image files and PDFs
    if (file.mimetype.startsWith('image/') || file.mimetype === 'application/pdf') {
      cb(null, true);
    } else {
      cb(new Error('Only image and PDF files are allowed'), false);
    }
  },
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB limit
  }
});

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Swagger UI integration
require('./swagger')(app);

// Initialize with mock data
let expenses = generateMockExpenses();
let expenseCounter = expenses.length + 1;

app.get('/health', (req, res) => res.json({status: 'ok', service: 'expense-service'}));

// Get all expenses for a user
app.get('/expenses', (req, res) => {
  const { userId } = req.query;
  if (userId) {
    const userExpenses = expenses.filter(exp => exp.userId === userId);
    return res.json(userExpenses);
  }
  res.json(expenses);
});

// Get specific expense
app.get('/expenses/:id', (req, res) => {
  const expense = expenses.find(exp => exp.id === req.params.id);
  if (!expense) {
    return res.status(404).json({ error: 'Expense not found' });
  }
  res.json(expense);
});

// Submit expense
app.post('/expense', upload.single('receipt'), (req, res) => {
  const { userId, amount, date, description } = req.body;
  
  if (!userId || !amount || !date || !description) {
    return res.status(400).json({ 
      error: 'Missing required fields: userId, amount, date, description' 
    });
  }

  const expense = {
    id: `exp_${String(expenseCounter++).padStart(3, '0')}`,
    userId,
    userName: `User ${userId}`, // In real app, fetch from user service
    amount: parseFloat(amount),
    description,
    date,
    status: 'pending',
    receiptPath: req.file ? req.file.path : null,
    createdAt: new Date().toISOString(),
    updatedAt: null,
    approvedBy: null,
    rejectionReason: null
  };

  expenses.push(expense);
  res.json({ message: 'Expense submitted successfully', expenseId: expense.id });
});

// Admin endpoints
// Get all expenses (admin only)
app.get('/admin/expenses', (req, res) => {
  const { status } = req.query;
  let filteredExpenses = expenses;
  
  if (status) {
    filteredExpenses = expenses.filter(exp => exp.status === status);
  }
  
  res.json(filteredExpenses);
});

// Approve expense
app.put('/admin/expenses/:id/approve', (req, res) => {
  const { approvedBy } = req.body;
  const expense = expenses.find(exp => exp.id === req.params.id);
  
  if (!expense) {
    return res.status(404).json({ error: 'Expense not found' });
  }
  
  if (expense.status !== 'pending') {
    return res.status(400).json({ error: 'Can only approve pending expenses' });
  }
  
  expense.status = 'approved';
  expense.approvedBy = approvedBy;
  expense.updatedAt = new Date().toISOString();
  expense.rejectionReason = null;
  
  res.json({ message: 'Expense approved successfully', expense });
});

// Reject expense
app.put('/admin/expenses/:id/reject', (req, res) => {
  const { rejectionReason, rejectedBy } = req.body;
  const expense = expenses.find(exp => exp.id === req.params.id);
  
  if (!expense) {
    return res.status(404).json({ error: 'Expense not found' });
  }
  
  if (!rejectionReason) {
    return res.status(400).json({ error: 'Rejection reason is required' });
  }
  
  expense.status = 'rejected';
  expense.rejectionReason = rejectionReason;
  expense.updatedAt = new Date().toISOString();
  expense.approvedBy = null;
  
  res.json({ message: 'Expense rejected successfully', expense });
});

// Request more details
app.put('/admin/expenses/:id/request-details', (req, res) => {
  const { message, requestedBy } = req.body;
  const expense = expenses.find(exp => exp.id === req.params.id);
  
  if (!expense) {
    return res.status(404).json({ error: 'Expense not found' });
  }
  
  if (!message) {
    return res.status(400).json({ error: 'Message is required' });
  }
  
  expense.status = 'needsMoreDetails';
  expense.rejectionReason = `More details requested: ${message}`;
  expense.updatedAt = new Date().toISOString();
  
  res.json({ message: 'Request for more details sent successfully', expense });
});

// Get receipt file
app.get('/expenses/:id/receipt', (req, res) => {
  const expense = expenses.find(exp => exp.id === req.params.id);
  
  if (!expense || !expense.receiptPath) {
    return res.status(404).json({ error: 'Receipt not found' });
  }
  
  // In real implementation, serve the actual file
  res.sendFile(path.resolve(expense.receiptPath));
});

// Serve uploaded files
app.use('/uploads', express.static('uploads'));

const PORT = process.env.PORT || 4003;
app.listen(PORT, () => console.log(`expense-service listening on ${PORT}`));
