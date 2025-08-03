import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tilak_mitra_mandal/api/expense_api.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpensesPage extends StatefulWidget {
  final String collectionName;
  final String token;

  const ExpensesPage({required this.collectionName, required this.token});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  List<Map<String, dynamic>> _expenses = [];
  final picker = ImagePicker();
  final uuid = Uuid();
  bool _isLoading = true;
  String? _error;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    _loadExpenses();
  }

  Future<void> _checkUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userRole = prefs.getString('user_role') ?? '';
      print("role $userRole");
      setState(() {
        _isAdmin = userRole.toLowerCase() == 'admin';
        print(_isAdmin);
      });
    } catch (e) {
      setState(() {
        _isAdmin = false;
      });
    }
  }

  Future<void> _loadExpenses() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final expenses = await ExpenseApi.getExpenses(widget.token);

      setState(() {
        _expenses =
            expenses
                .map<Map<String, dynamic>>(
                  (dynamic item) => {
                    'id': (item['_id'] ?? item['id'])?.toString() ?? '',
                    'amount': _parseToDouble(item['amount']),
                    'what':
                        (item['purpose'] ?? item['description'] ?? '')
                            .toString(),
                    'by':
                        (item['spentBy'] ?? item['collectedBy'] ?? '')
                            .toString(),
                    'description': (item['description'] ?? '').toString(),
                    'image': item['receiptUrl']?.toString(),
                    'date': _parseDate(item['date']),
                  },
                )
                .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Helper method to safely parse numbers to double
  double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  // Helper method to safely parse dates
  DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Future<void> _addExpenseEntry() async {
    await _showExpenseDialog();
  }

  Future<void> _editExpense(Map<String, dynamic> expense) async {
    await _showExpenseDialog(expense: expense);
  }

  Future<void> _showExpenseDialog({Map<String, dynamic>? expense}) async {
    if (!_isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            expense == null
                ? 'Only administrators can add expenses'
                : 'Only administrators can edit expenses',
          ),
          backgroundColor: const Color(0xFFD32F2F),
        ),
      );
      return;
    }

    final bool isEditing = expense != null;
    final TextEditingController amountController = TextEditingController(
      text: isEditing ? expense['amount'].toString() : '',
    );
    final TextEditingController purposeController = TextEditingController(
      text: isEditing ? expense['what'] : '',
    );
    final TextEditingController byController = TextEditingController(
      text: isEditing ? expense['by'] : '',
    );
    final TextEditingController descriptionController = TextEditingController(
      text: isEditing ? expense['description'] : '',
    );
    File? image;

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5722).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit : Icons.remove_circle_outline,
                      color: const Color(0xFFFF5722),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEditing ? "Edit Expense" : "Add Expense",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Amount Spent",
                        prefixText: "₹ ",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF5722),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: purposeController,
                      decoration: InputDecoration(
                        labelText: "Purpose",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF5722),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: byController,
                      decoration: InputDecoration(
                        labelText: "Spent By",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF5722),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Description (Optional)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF5722),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            try {
                              final picked = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 80,
                              );
                              if (picked != null) {
                                final extension =
                                    picked.path.toLowerCase().split('.').last;
                                final allowedExtensions = [
                                  'jpg',
                                  'jpeg',
                                  'png',
                                  'gif',
                                  'bmp',
                                  'webp',
                                ];

                                if (allowedExtensions.contains(extension)) {
                                  setDialogState(() {
                                    image = File(picked.path);
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please select a valid image file (JPG, PNG, etc.)',
                                      ),
                                      backgroundColor: Color(0xFFD32F2F),
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error selecting image: ${e.toString()}',
                                  ),
                                  backgroundColor: const Color(0xFFD32F2F),
                                ),
                              );
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                image != null
                                    ? Icons.check_circle
                                    : Icons.camera_alt,
                                color:
                                    image != null
                                        ? const Color(0xFFFF5722)
                                        : Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                image != null
                                    ? "New Image Selected"
                                    : isEditing && expense['image'] != null
                                    ? "Change Receipt Image"
                                    : "Pick Receipt Image",
                                style: TextStyle(
                                  color:
                                      image != null
                                          ? const Color(0xFFFF5722)
                                          : Colors.grey[600],
                                  fontWeight:
                                      image != null
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (isEditing &&
                        expense['image'] != null &&
                        image == null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.image,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Current receipt will be kept",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5722),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final amount = double.tryParse(
                      amountController.text.trim(),
                    );
                    final purpose = purposeController.text.trim();
                    final spentBy = byController.text.trim();

                    if (amount != null &&
                        amount > 0 &&
                        purpose.isNotEmpty &&
                        spentBy.isNotEmpty) {
                      Navigator.of(context).pop();

                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        if (isEditing) {
                          await ExpenseApi.updateExpense(
                            id: expense['id'],
                            token: widget.token,
                            amount: amount,
                            purpose: purpose,
                            spentBy: spentBy,
                            description:
                                descriptionController.text.trim().isNotEmpty
                                    ? descriptionController.text.trim()
                                    : '',
                            receipt: image,
                          );
                        } else {
                          await ExpenseApi.addExpense(
                            token: widget.token,
                            amount: amount,
                            purpose: purpose,
                            spentBy: spentBy,
                            description:
                                descriptionController.text.trim().isNotEmpty
                                    ? descriptionController.text.trim()
                                    : '',
                            receipt: image,
                          );
                        }

                        await _loadExpenses();

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEditing
                                    ? 'Expense updated successfully!'
                                    : 'Expense added successfully!',
                              ),
                              backgroundColor: const Color(0xFFFF5722),
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() {
                          _isLoading = false;
                        });

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: const Color(0xFFD32F2F),
                            ),
                          );
                        }
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please fill in all required fields with valid data',
                          ),
                          backgroundColor: Color(0xFFD32F2F),
                        ),
                      );
                    }
                  },
                  child: Text(
                    isEditing ? "Update" : "Save",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteExpense(String id) async {
    try {
      await ExpenseApi.deleteExpense(id, widget.token);
      await _loadExpenses();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense deleted successfully!'),
          backgroundColor: Color(0xFFFF5722),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting expense: ${e.toString()}'),
          backgroundColor: const Color(0xFFD32F2F),
        ),
      );
    }
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.error,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showExpenseDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5722).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Color(0xFFFF5722),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Expense Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow(
                  'Amount',
                  '₹${(item['amount'] as double).toStringAsFixed(2)}',
                ),
                _buildDetailRow(
                  'Purpose',
                  (item['what'] as String).isEmpty
                      ? 'Not specified'
                      : item['what'] as String,
                ),
                _buildDetailRow(
                  'Spent By',
                  (item['by'] as String).isEmpty
                      ? 'Anonymous'
                      : item['by'] as String,
                ),
                _buildDetailRow(
                  'Date',
                  DateFormat('MMM dd, yyyy').format(item['date'] as DateTime),
                ),
                if ((item['description'] as String).isNotEmpty)
                  _buildDetailRow('Description', item['description'] as String),
                if (item['image'] != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Receipt Image:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _showImageDialog(item['image'] as String);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFFF5722).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          item['image'] as String,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            if (_isAdmin) ...[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _editExpense(item);
                },
                child: const Text(
                  'Edit',
                  style: TextStyle(color: Color(0xFFFF5722)),
                ),
              ),
            ],
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFFFF5722)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Color(0xFF2E2E2E)),
            ),
          ),
        ],
      ),
    );
  }

  double get total =>
      _expenses.fold<double>(0.0, (sum, e) => sum + (e['amount'] as double));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: RefreshIndicator(
        onRefresh: _loadExpenses,
        color: const Color(0xFFFF5722),
        child: Stack(
          children: [
            Positioned(
              bottom: 100,
              left: -50,
              child: Opacity(
                opacity: 0.04,
                child: Image.asset(
                  'lib/assets/tilak.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 180,
                  floating: false,
                  pinned: true,
                  backgroundColor: const Color(0xFFFF5722),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFD32F2F),
                            Color(0xFFFF5722),
                            Color(0xFFFF7043),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 60,
                            right: -20,
                            child: Icon(
                              Icons.remove_circle_outline,
                              size: 120,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.collectionName,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  "Total expenses: ₹${total.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    if (_isAdmin)
                      Container(
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: _addExpenseEntry,
                        ),
                      ),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver:
                      _isLoading
                          ? SliverFillRemaining(
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFFF5722,
                                      ).withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFFF5722,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Color(0xFFFF5722),
                                              ),
                                          strokeWidth: 3,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Loading Expenses...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF2E2E2E),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Please wait while we fetch your data',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          : _error != null
                          ? SliverFillRemaining(child: _buildErrorState())
                          : _expenses.isEmpty
                          ? SliverFillRemaining(child: _buildEmptyState())
                          : SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final item = _expenses[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildExpenseCard(item),
                              );
                            }, childCount: _expenses.length),
                          ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFE0DD).withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Dismissible(
        key: Key(item['id'] as String),
        direction:
            _isAdmin ? DismissDirection.endToStart : DismissDirection.none,
        background:
            _isAdmin
                ? Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 24,
                  ),
                )
                : null,
        confirmDismiss:
            _isAdmin
                ? (direction) async {
                  return await showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Delete Expense'),
                          content: const Text(
                            'Are you sure you want to delete this expense?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Color(0xFFD32F2F)),
                              ),
                            ),
                          ],
                        ),
                  );
                }
                : null,
        onDismissed:
            _isAdmin
                ? (direction) {
                  _deleteExpense(item['id'] as String);
                }
                : null,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showExpenseDetails(item),
            onLongPress: _isAdmin ? () => _editExpense(item) : null,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5722).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.remove_circle,
                          color: Color(0xFFFF5722),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "₹${(item['amount'] as double).toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E2E2E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (item['what'] as String).isNotEmpty
                                  ? item['what'] as String
                                  : 'No purpose specified',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF424242),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item['image'] != null)
                        GestureDetector(
                          onTap:
                              () => _showImageDialog(item['image'] as String),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFFF5722).withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                item['image'] as String,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          (item['by'] as String).isNotEmpty
                              ? item['by'] as String
                              : 'Anonymous',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          DateFormat(
                            'MMM dd, yyyy',
                          ).format(item['date'] as DateTime),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5722).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.remove_circle_outline,
              size: 80,
              color: const Color(0xFFFF5722).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Expenses Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E2E2E),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Start tracking expenses\nfor ${widget.collectionName}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          if (_isAdmin)
            ElevatedButton.icon(
              onPressed: _addExpenseEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5722),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Add First Expense",
                style: TextStyle(color: Colors.white),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Only administrators can add new expenses',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 80,
              color: const Color(0xFFD32F2F).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Error Loading Expenses',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E2E2E),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _error ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _loadExpenses,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5722),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text("Retry", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
