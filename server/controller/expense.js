const Expense = require('../models/expense');
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

// NEW: Get total expenses
exports.getTotalExpenses = async (req, res) => {
  try {
    const result = await Expense.aggregate([
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
    console.error('❌ Failed to get total expenses:', err);
    res.status(500).json({ error: 'Failed to get total expenses' });
  }
};

exports.addExpense = async (req, res) => {
  try {
    const { amount, description, purpose, spentBy } = req.body;
    const file = req.file;

    if (!amount || !description || !purpose || !spentBy) {
      return res.status(400).json({
        error: 'Amount, description, purpose, and spentBy are required',
        received: { amount, description, purpose, spentBy },
      });
    }

    const parsedAmount = parseFloat(amount);
    if (isNaN(parsedAmount) || parsedAmount <= 0) {
      return res.status(400).json({ error: 'Amount must be a positive number' });
    }

    const receiptUrl = file?.path || null;

    const newExpense = new Expense({
      amount: parsedAmount,
      description: description.trim(),
      purpose: purpose.trim(),
      spentBy: spentBy.trim(),
      receiptUrl,
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
        console.log('✅ Cloudinary file deleted:', publicId);
      } catch (err) {
        console.warn('⚠️ Cloudinary delete error:', err.message);
      }
    }

    await Expense.findByIdAndDelete(id);
    res.json({ message: 'Expense deleted successfully' });
  } catch (err) {
    console.error('❌ Failed to delete expense:', err);
    res.status(500).json({ error: 'Failed to delete expense' });
  }
};

exports.updateExpense = async (req, res) => {
  try {
    const { id } = req.params;
    const { amount, description, purpose, spentBy } = req.body;
    const file = req.file;

    const expense = await Expense.findById(id);
    if (!expense) {
      return res.status(404).json({ error: 'Expense not found' });
    }

    const parsedAmount = parseFloat(amount);
    if (isNaN(parsedAmount) || parsedAmount <= 0) {
      return res.status(400).json({ error: 'Amount must be a positive number' });
    }

    expense.amount = parsedAmount;
    expense.description = description.trim();
    expense.purpose = purpose.trim();
    expense.spentBy = spentBy.trim();

    if (file) {
      if (expense.receiptUrl) {
        try {
          const parts = expense.receiptUrl.split('/');
          const folderAndPublicId = parts.slice(-2).join('/').split('.')[0];
          await cloudinary.uploader.destroy(folderAndPublicId);
        } catch (err) {
          console.warn('⚠️ Cloudinary delete error:', err.message);
        }
      }
      expense.receiptUrl = file.path;
    }

    const updated = await expense.save();
    res.json(updated);
  } catch (err) {
    console.error('❌ Failed to update expense:', err);
    res.status(500).json({ error: 'Failed to update expense' });
  }
};