const Expense = require('../models/Expense');
const cloudinary = require('../utils/cloudinary');

exports.getExpenses = async (req, res) => {
  try {
    const data = await Expense.find().sort({ date: -1 });
    res.json(data);
  } catch (err) {
    console.error('❌ Failed to fetch expenses:', err);
    res.status(500).json({ error: 'Failed to fetch expenses' });
  }
};

exports.addExpense = async (req, res) => {
  try {
    const { description, spentBy, amount } = req.body;
    const file = req.file;

    if (!description || !spentBy) {
      return res.status(400).json({ error: 'Description and spentBy are required fields' });
    }

    const parsedAmount = amount ? parseFloat(amount) : 0;
    if (amount && (isNaN(parsedAmount) || parsedAmount <= 0)) {
      return res.status(400).json({ error: 'Amount must be a positive number' });
    }

    const receiptUrl = file?.path || null;
    if (receiptUrl) {
      console.log('✅ Receipt uploaded:', receiptUrl);
    } else {
      console.log('⚠️ No receipt uploaded');
    }

    const newExpense = new Expense({
      description,
      spentBy,
      amount: parsedAmount || undefined,
      receiptUrl,
      date: new Date() // fallback if not auto-set
    });

    const saved = await newExpense.save();
    res.status(201).json(saved);
  } catch (err) {
    console.error('❌ Failed to add expense:', err);
    res.status(500).json({ error: 'Failed to add expense' });
  }
};

exports.deleteExpense = async (req, res) => {
  try {
    const { id } = req.params;
    const expense = await Expense.findById(id);

    if (!expense) {
      return res.status(404).json({ error: 'Expense not found' });
    }

    if (expense.receiptUrl) {
      try {
        const publicId = expense.receiptUrl.split('/').slice(-2).join('/').split('.')[0];
        await cloudinary.uploader.destroy(publicId);
        console.log('✅ Deleted from Cloudinary:', publicId);
      } catch (err) {
        console.warn('⚠️ Failed to delete from Cloudinary:', err.message);
      }
    }

    await Expense.findByIdAndDelete(id);
    res.json({ message: 'Expense deleted successfully' });
  } catch (err) {
    console.error('❌ Failed to delete expense:', err);
    res.status(500).json({ error: 'Failed to delete expense' });
  }
};
