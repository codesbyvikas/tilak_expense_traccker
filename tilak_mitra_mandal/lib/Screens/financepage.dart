import 'package:flutter/material.dart';
import 'package:tilak_mitra_mandal/Screens/collectionspage.dart';
import 'package:tilak_mitra_mandal/Screens/expensespage.dart';

class CollectionDetailPage extends StatelessWidget {
  final String collectionName;
  const CollectionDetailPage({required this.collectionName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // Background tilak image
          Positioned(
            top: 150,
            right: -50,
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'lib/assets/tilak.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Main content
          CustomScrollView(
            slivers: [
              // Custom App Bar with Gradient
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFFD32F2F),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true, // 👈 This is key
                  titlePadding: const EdgeInsets.only(bottom: 16),
                  title: Text(
                    collectionName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),

                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFD32F2F),
                          Color(0xFFFF5722),
                          Color(0xFFFF9800),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 60,
                          right: -20,
                          child: Icon(
                            Icons.temple_hindu,
                            size: 120,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 20),
                    // Summary Stats Card
                    _buildSummaryCard(),
                    const SizedBox(height: 30),
                    // Action Buttons
                    _buildActionButton(
                      context,
                      'Collections',
                      'Manage money collected',
                      Icons.add_circle_outline,
                      const Color(0xFF4CAF50),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => CollectionsPage(
                                collectionName: collectionName,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildActionButton(
                      context,
                      'Expenses',
                      'Track money spent',
                      Icons.remove_circle_outline,
                      const Color(0xFFFF5722),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  ExpensesPage(collectionName: collectionName),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFCDD2).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
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
                  Icons.analytics,
                  color: Color(0xFFFF5722),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Financial Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E2E2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Collection',
                  '₹15,000',
                  Icons.trending_up,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Total Expenses',
                  '₹8,500',
                  Icons.trending_down,
                  const Color(0xFFFF5722),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      color: Color(0xFF2196F3),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Remaining Balance',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '₹6,500',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E2E2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFCDD2).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2E2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
