// Mock data generator for expenses
function generateMockExpenses() {
  const users = [
    { id: 'user_001', name: 'John Doe' },
    { id: 'user_002', name: 'Jane Smith' },
    { id: 'user_003', name: 'Bob Johnson' },
    { id: 'user_004', name: 'Alice Brown' },
    { id: 'user_005', name: 'Charlie Wilson' },
    { id: 'user_006', name: 'Diana Chen' },
    { id: 'user_007', name: 'Erik Davis' },
    { id: 'user_008', name: 'Fiona Garcia' }
  ];

  const descriptions = [
    'Client dinner meeting',
    'Office supplies purchase',
    'Travel expenses - flight',
    'Hotel accommodation',
    'Taxi fare to airport',
    'Conference registration fee',
    'Team lunch',
    'Parking fees',
    'Mobile phone bill',
    'Internet service',
    'Software license',
    'Office equipment',
    'Training course fee',
    'Business cards printing',
    'Marketing materials',
    'Fuel expenses',
    'Car maintenance',
    'Office rent utilities'
  ];

  const statuses = ['pending', 'approved', 'rejected', 'needsMoreDetails'];
  const expenses = [];

  for (let i = 1; i <= 50; i++) {
    const user = users[Math.floor(Math.random() * users.length)];
    const description = descriptions[Math.floor(Math.random() * descriptions.length)];
    const status = statuses[Math.floor(Math.random() * statuses.length)];
    const amount = (Math.random() * 500 + 10).toFixed(2);
    
    // Generate random date within last 30 days
    const date = new Date();
    date.setDate(date.getDate() - Math.floor(Math.random() * 30));
    
    const createdAt = new Date(date);
    createdAt.setHours(createdAt.getHours() - Math.floor(Math.random() * 24));

    const expense = {
      id: `exp_${String(i).padStart(3, '0')}`,
      userId: user.id,
      userName: user.name,
      amount: parseFloat(amount),
      description: description,
      date: date.toISOString().split('T')[0],
      status: status,
      receiptPath: Math.random() > 0.3 ? `uploads/receipt_${i}.jpg` : null,
      createdAt: createdAt.toISOString(),
      updatedAt: status !== 'pending' ? new Date().toISOString() : null,
      approvedBy: status === 'approved' ? 'Admin' : null,
      rejectionReason: status === 'rejected' ? 'Insufficient documentation' : 
                      status === 'needsMoreDetails' ? 'Please provide more details about this expense' : null
    };

    expenses.push(expense);
  }

  return expenses;
}

module.exports = { generateMockExpenses };