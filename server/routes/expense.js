const express = require('express');
const router = express.Router();
const { auth, isAdmin } = require('../middlewares/auth');
const { getCollections, addCollection, deleteCollection } = require('../controller/collection');
const multer = require('multer');
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const cloudinary = require('../utils/cloudinary');

const storage = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: 'collections',
    allowed_formats: ['jpg', 'jpeg', 'png', 'pdf'],
    resource_type: 'auto',
  },
});

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

router.get('/', auth, getCollections);
router.post('/', auth, isAdmin, upload.single('receipt'), addCollection);
router.delete("/:id", auth, isAdmin, deleteCollection);

module.exports = router;
