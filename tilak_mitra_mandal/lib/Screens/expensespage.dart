import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class ExpensesPage extends StatefulWidget {
  final String collectionName;
  const ExpensesPage({required this.collectionName});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final List<Map<String, dynamic>> _expenses = [];
  final picker = ImagePicker();
  final uuid = Uuid();

  Future<void> _addExpenseEntry() async {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController whatController = TextEditingController();
    final TextEditingController byController = TextEditingController();
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
                    child: const Icon(
                      Icons.remove_circle_outline,
                      color: Color(0xFFFF5722),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Add Expense",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      controller: whatController,
                      decoration: InputDecoration(
                        labelText: "For What",
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
                        labelText: "Spent By (Optional)",
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
                            final picked = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (picked != null) {
                              setDialogState(() {
                                image = File(picked.path);
                              });
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
                                    ? "Image Selected"
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
                  onPressed: () {
                    final amount = double.tryParse(
                      amountController.text.trim(),
                    );
                    if (amount != null) {
                      setState(() {
                        _expenses.add({
                          'id': uuid.v4(),
                          'amount': amount,
                          'what': whatController.text.trim(),
                          'by': byController.text.trim(),
                          'image': image,
                          'date': DateTime.now(),
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showImageDialog(File image) {
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
                    child: Image.file(image, fit: BoxFit.contain),
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

  double get total => _expenses.fold(0.0, (sum, e) => sum + e['amount']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // Background tilak image
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
          // Main content
          CustomScrollView(
            slivers: [
              // Custom App Bar
              SliverAppBar(
                expandedHeight: 180,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFFFF5722),
                flexibleSpace: FlexibleSpaceBar(
                  // title: const Text(
                  //   "Expenses",
                  //   style: TextStyle(
                  //     color: Colors.white,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
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
              // Content
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver:
                    _expenses.isEmpty
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
                        "₹${item['amount'].toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2E2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['what']?.isNotEmpty == true
                            ? item['what']
                            : 'No description',
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
                    onTap: () => _showImageDialog(item['image']),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(item['image']),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          color: const Color(0xFFFF5722).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.black.withOpacity(0.1),
                        ),
                        child: const Icon(
                          Icons.zoom_in,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  item['by']?.isNotEmpty == true ? item['by'] : 'Anonymous',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(item['date']),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
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
          ElevatedButton.icon(
            onPressed: _addExpenseEntry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5722),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "Add First Expense",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
