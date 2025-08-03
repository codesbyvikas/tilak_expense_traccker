import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class CollectionsPage extends StatefulWidget {
  final String collectionName;
  const CollectionsPage({required this.collectionName});

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  final List<Map<String, dynamic>> _collections = [];
  final picker = ImagePicker();
  final uuid = Uuid();

  Future<void> _addCollectionEntry() async {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController byController = TextEditingController();
    final TextEditingController fromController = TextEditingController();
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
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF4CAF50),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Add Collection",
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
                        labelText: "Amount Received",
                        prefixText: "₹ ",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: fromController,
                      decoration: InputDecoration(
                        labelText: "Collected From",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: byController,
                      decoration: InputDecoration(
                        labelText: "Collected By (Optional)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF4CAF50),
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
                                        ? const Color(0xFF4CAF50)
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
                                          ? const Color(0xFF4CAF50)
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
                    backgroundColor: const Color(0xFF4CAF50),
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
                        _collections.add({
                          'id': uuid.v4(),
                          'amount': amount,
                          'from': fromController.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // Background tilak image
          Positioned(
            bottom: 100,
            right: -50,
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
                backgroundColor: const Color(0xFF4CAF50),
                flexibleSpace: FlexibleSpaceBar(
                  // title: Text(
                  //   "Collections",
                  //   style: const TextStyle(
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
                          Color(0xFF4CAF50),
                          Color(0xFF66BB6A),
                          Color(0xFF81C784),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 60,
                          right: -20,
                          child: Icon(
                            Icons.add_circle_outline,
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
                                "Total  Collections: ₹${total.toStringAsFixed(2)}",
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
                      onPressed: _addCollectionEntry,
                    ),
                  ),
                ],
              ),
              // Content
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver:
                    _collections.isEmpty
                        ? SliverFillRemaining(child: _buildEmptyState())
                        : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final item = _collections[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildCollectionCard(item),
                            );
                          }, childCount: _collections.length),
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double get total => _collections.fold(0.0, (sum, e) => sum + e['amount']);

  Widget _buildCollectionCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8F5E8).withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16), // Reduced padding from 20 to 16
        child: IntrinsicHeight(
          // Added to maintain consistent height
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Changed to start alignment
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add_circle,
                  color: Color(0xFF4CAF50),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12), // Reduced from 16 to 12
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "₹${item['amount'].toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E2E2E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // From field
                    if (item['from']?.isNotEmpty == true)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.store_outlined,
                              size: 14, // Reduced from 16 to 14
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item['from'],
                                style: TextStyle(
                                  fontSize: 13, // Reduced from 14 to 13
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // By and Date in one row
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 14, // Reduced from 16 to 14
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item['by']?.isNotEmpty == true
                                      ? item['by']
                                      : 'Anonymous',
                                  style: TextStyle(
                                    fontSize: 13, // Reduced from 14 to 13
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14, // Reduced from 16 to 14
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  DateFormat('MMM d').format(
                                    item['date'],
                                  ), // Single digit day format
                                  style: TextStyle(
                                    fontSize: 12, // Reduced from 14 to 12
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (item['image'] != null) ...[
                const SizedBox(width: 8), // Reduced from 12 to 8
                GestureDetector(
                  onTap: () => _showImageDialog(item['image']),
                  child: Container(
                    width: 45, // Reduced from 50 to 45
                    height: 45, // Reduced from 50 to 45
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(item['image']),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
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
                        size: 18, // Reduced from 20 to 18
                      ),
                    ),
                  ),
                ),
              ],
            ],
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
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_circle_outline,
              size: 80,
              color: const Color(0xFF4CAF50).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Collections Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E2E2E),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Start adding money collected\nfor ${widget.collectionName}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _addCollectionEntry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "Add First Collection",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
