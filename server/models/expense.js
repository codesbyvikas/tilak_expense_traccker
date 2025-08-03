const mongoose = require('mongoose');

const expenseSchema = new mongoose.Schema({
  amount: {
    type: Number,
    required: true,
  },
  description: {
    type: String,
    // required: true,
  },
  purpose: {
    type: String,
    // required: true, // Purpose for spending
  },
  spentBy: {
    type: String,
    // required: true,
  },
  receiptUrl: String,
  date: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Expense', expenseSchema);