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

exports.addCollection = async (req, res) => {
  try {
    const { amount, collectedBy, description } = req.body;
    const file = req.file;

    if (!amount || !collectedBy) {
      return res.status(400).json({ error: 'Amount and collectedBy are required fields' });
    }

    const parsedAmount = parseFloat(amount);
    if (isNaN(parsedAmount) || parsedAmount <= 0) {
      return res.status(400).json({ error: 'Amount must be a positive number' });
    }

    const receiptUrl = file?.path || null;
    if (receiptUrl) {
      console.log('✅ Receipt uploaded:', receiptUrl);
    } else {
      console.log('⚠️ No receipt uploaded');
    }

    const newCollection = new Collection({
      amount: parsedAmount,
      collectedBy,
      description: description || '',
      receiptUrl,
      date: new Date() // fallback if not auto-set
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

    // Delete receipt from Cloudinary
    if (collection.receiptUrl) {
      try {
        const publicId = collection.receiptUrl.split('/').slice(-2).join('/').split('.')[0];
        await cloudinary.uploader.destroy(publicId);
        console.log('✅ Deleted from Cloudinary:', publicId);
      } catch (err) {
        console.warn('⚠️ Failed to delete from Cloudinary:', err.message);
      }
    }

    await Collection.findByIdAndDelete(id);
    res.json({ message: 'Collection deleted successfully' });
  } catch (err) {
    console.error('❌ Failed to delete collection:', err);
    res.status(500).json({ error: 'Failed to delete collection' });
  }
};
