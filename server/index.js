const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const cors = require('cors');
dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('MongoDB connected'))
  .catch(err => console.error(err));

  const User = require('./models/User');

const seedUsers = async () => {
  const existing = await User.find();
  if (existing.length) return;

  await User.insertMany([
    { name: 'Admin', email: 'admin@tilak.com', password: 'Reetesh@2025', role: 'admin' },
    { name: 'Member1', email: 'm1@tilak.com', password: 'member2025', role: 'member' },
    { name: 'Member2', email: 'm2@tilak.com', password: 'member2025', role: 'member' },
    { name: 'Member3', email: 'm3@tilak.com', password: 'member2025', role: 'member' },
    { name: 'Member4', email: 'm4@tilak.com', password: 'member2025', role: 'member' },
  ]);

  console.log('Users seeded');
};

seedUsers();


// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/collections', require('./routes/collection'));
app.use('/api/expenses', require('./routes/expense'));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
