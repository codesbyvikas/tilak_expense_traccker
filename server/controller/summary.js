// Optional: Create a new file called controller/summary.js
// This provides a single endpoint for all financial summary data

const Expense = require('../models/expense');
const Collection = require('../models/collection');

exports.getFinancialSummary = async (req, res) => {
  try {
    const [expenseResult, collectionResult] = await Promise.all([
      Expense.aggregate([
        {
          $group: {
            _id: null,
            totalAmount: { $sum: '$amount' },
            totalCount: { $sum: 1 }
          }
        }
      ]),
      Collection.aggregate([
        {
          $group: {
            _id: null,
            totalAmount: { $sum: '$amount' },
            totalCount: { $sum: 1 }
          }
        }
      ])
    ]);

    const totalExpenses = expenseResult.length > 0 ? expenseResult[0].totalAmount : 0;
    const expenseCount = expenseResult.length > 0 ? expenseResult[0].totalCount : 0;
    
    const totalCollections = collectionResult.length > 0 ? collectionResult[0].totalAmount : 0;
    const collectionCount = collectionResult.length > 0 ? collectionResult[0].totalCount : 0;
    
    const remainingBalance = totalCollections - totalExpenses;

    res.json({
      totalCollections,
      totalExpenses,
      remainingBalance,
      collectionCount,
      expenseCount
    });
  } catch (err) {
    console.error('❌ Failed to get financial summary:', err);
    res.status(500).json({ error: 'Failed to get financial summary' });
  }
};