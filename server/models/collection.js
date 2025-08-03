const mongoose = require('mongoose');

const collectionSchema = new mongoose.Schema({
  amount: Number,
  collectedBy: String,
  receiptUrl: String,
  date: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Collection', collectionSchema);
