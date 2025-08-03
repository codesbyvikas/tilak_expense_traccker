const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: String,
  email: { type: String, unique: true },
  password: String, // plaintext (not secure, but simple)
  role: { type: String, enum: ['admin', 'member'], default: 'member' }
});

module.exports = mongoose.model('User', userSchema);
