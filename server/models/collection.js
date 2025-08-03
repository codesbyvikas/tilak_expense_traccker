const mongoose = require('mongoose');

const collectionSchema = new mongoose.Schema({
  amount: {
    type: Number,
    required: true,
  },
  collectedBy: {
    type: String,
    required: true,
  },
  collectedFrom: {
    type: String,
    required: true,
    defaut: "vikas",
  },
  description: String,
  receiptUrl: String,
  date: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Collection', collectionSchema);
