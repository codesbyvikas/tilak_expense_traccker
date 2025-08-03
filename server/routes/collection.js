const express = require('express');
const router = express.Router();
const { auth, isAdmin } = require('../middlewares/auth');
const {
  getCollections,
  getTotalCollections, // NEW: Import the new function
  addCollection,
  deleteCollection,
} = require('../controller/collection');

const multer = require('multer');
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const cloudinary = require('../utils/cloudinary');

// Configure Cloudinary Storage
const storage = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: 'collections',
    allowed_formats: ['jpg', 'jpeg', 'png', 'pdf'],
    resource_type: 'auto',
  },
});

// Multer middleware
const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/') || file.mimetype === 'application/pdf') {
      cb(null, true);
    } else {
      cb(new Error('Only image files and PDFs are allowed!'), false);
    }
  },
});

// Routes
router.get('/', auth, getCollections);
router.get('/total', auth, getTotalCollections); // NEW: Add this route
router.post('/', auth, isAdmin, upload.single('receipt'), addCollection);
router.delete('/:id', auth, isAdmin, deleteCollection);

module.exports = router;