const express = require('express');
const router = express.Router();
const { auth, isAdmin } = require('../middlewares/auth');
const {
  getExpenses,
  getTotalExpenses, 
  addExpense,
  deleteExpense,
  updateExpense,
} = require('../controller/expense');

const multer = require('multer');
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const cloudinary = require('../utils/cloudinary');

// Configure Cloudinary Storage
const storage = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: 'expenses',
    allowed_formats: ['jpg', 'jpeg', 'png', 'pdf'],
    resource_type: 'auto',
  },
});

// Multer middleware setup
const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // Max 5MB
  fileFilter: (req, file, cb) => {
    if (
      file.mimetype.startsWith('image/') ||
      file.mimetype === 'application/pdf'
    ) {
      cb(null, true);
    } else {
      cb(new Error('Only image files and PDFs are allowed!'), false);
    }
  },
});

// Routes
router.get('/', auth, getExpenses);
router.get('/total', auth, getTotalExpenses); // NEW: Add this route
router.post('/', auth, upload.single('receipt'), addExpense);
router.put('/:id', auth, upload.single('receipt'), updateExpense);
router.delete('/:id', auth, deleteExpense);

module.exports = router;