const Collection = require('../models/collection');
const cloudinary = require('../utils/cloudinary');

exports.getCollections = async (req, res) => {
  try {
    const data = await Collection.find().sort({ date: -1 });
    res.json(data);
  } catch (err) {
    console.error('❌ Failed to fetch collections:', err);
    res.status(500).json({ error: 'Failed to fetch collections' });
  }
};

// NEW: Get total collections
exports.getTotalCollections = async (req, res) => {
  try {
    const result = await Collection.aggregate([
      {
        $group: {
          _id: null,
          totalAmount: { $sum: '$amount' },
          totalCount: { $sum: 1 }
        }
      }
    ]);

    const total = result.length > 0 ? result[0].totalAmount : 0;
    const count = result.length > 0 ? result[0].totalCount : 0;

    res.json({
      totalAmount: total,
      totalCount: count
    });
  } catch (err) {
    console.error('❌ Failed to get total collections:', err);
    res.status(500).json({ error: 'Failed to get total collections' });
  }
};

exports.addCollection = async (req, res) => {
  try {
    const { amount, collectedBy, collectedFrom, description } = req.body;
    const file = req.file;

    if (!amount || !collectedBy || !collectedFrom) {
      return res.status(400).json({ error: 'Amount, collectedBy, and collectedFrom are required' });
    }

    const parsedAmount = parseFloat(amount);
    if (isNaN(parsedAmount) || parsedAmount <= 0) {
      return res.status(400).json({ error: 'Amount must be a positive number' });
    }

    const receiptUrl = file?.path || null;

    const newCollection = new Collection({
      amount: parsedAmount,
      collectedBy,
      collectedFrom,
      description: description || '',
      receiptUrl,
    });

    const saved = await newCollection.save();
    res.status(201).json(saved);
  } catch (err) {
    console.error('❌ Failed to add collection:', err);
    res.status(500).json({ error: 'Failed to add collection' });
  }
};

exports.deleteCollection = async (req, res) => {
  try {
    const { id } = req.params;
    const collection = await Collection.findById(id);

    if (!collection) {
      return res.status(404).json({ error: 'Collection not found' });
    }

    // Optional: Delete image from Cloudinary
    if (collection.receiptUrl) {
      try {
        const parts = collection.receiptUrl.split('/');
        const folderAndPublicId = parts.slice(-2).join('/').split('.')[0];
        await cloudinary.uploader.destroy(folderAndPublicId);
        console.log('✅ Cloudinary file deleted:', folderAndPublicId);
      } catch (err) {
        console.warn('⚠️ Cloudinary delete error:', err.message);
      }
    }

    await Collection.findByIdAndDelete(id);
    res.json({ message: 'Collection deleted successfully' });
  } catch (err) {
    console.error('❌ Failed to delete collection:', err);
    res.status(500).json({ error: 'Failed to delete collection' });
  }
};