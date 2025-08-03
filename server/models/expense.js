const mongoose = require('mongoose');

const expenseSchema = new mongoose.Schema({
  amount: Number,
  description: String,
  spentBy: String,
  receiptUrl: String,
  date: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Expense', expenseSchema);
