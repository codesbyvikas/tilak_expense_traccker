const router = require('express').Router();
const { auth, isAdmin } = require('../middleware/auth');
const Expense = require('../models/expense');
const multer = require('multer');
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const cloudinary = require('../utils/cloudinary');

const storage = new CloudinaryStorage({
  cloudinary,
  params: { folder: 'expenses' },
});
const upload = multer({ storage });

// View expenses (all users)
router.get('/', auth, async (req, res) => {
  const expenses = await Expense.find().sort({ date: -1 });
  res.json(expenses);
});

// Add expense (admin only)
router.post('/', auth, isAdmin, upload.single('receipt'), async (req, res) => {
  const { amount, spentBy, description } = req.body;
  const receiptUrl = req.file?.path;
  const entry = await Expense.create({ amount, spentBy, description, receiptUrl });
  res.json(entry);
});

module.exports = router;
