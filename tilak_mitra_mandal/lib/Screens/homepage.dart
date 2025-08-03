// homepage.dart
import 'package:flutter/material.dart';
import 'package:tilak_mitra_mandal/Screens/financepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tilak_mitra_mandal/Screens/loginpage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> collections = ['Ganesh Chaturthi 2025'];

  void _openCollection(String collectionName) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                CollectionDetailPage(collectionName: collectionName),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear token and user data
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // Main background with tilak images
          // Positioned(
          //   top: 100,
          //   right: -50,
          //   child: Opacity(
          //     opacity: 0.05,
          //     child: Container(
          //       width: 200,
          //       height: 200,
          //       decoration: const BoxDecoration(
          //         image: DecorationImage(
          //           image: AssetImage('lib/assets/tilak.png'),
          //           fit: BoxFit.contain,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          Positioned(
            bottom: 50,
            left: -30,
            child: Opacity(
              opacity: 0.04,
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/assets/tilak.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 300,
            left: 20,
            child: Opacity(
              opacity: 0.03,
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/assets/tilak.png'),
                    fit: BoxFit.contain,
                  ),
                ),
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
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    color: Colors.white,
                    onPressed: _logout,
                    tooltip: 'Logout',
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
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
                        const Positioned(
                          bottom: 20,
                          left: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back!',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Manage your festival expenses',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver:
                    collections.isEmpty
                        ? SliverFillRemaining(child: _buildEmptyState())
                        : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final collectionName = collections[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: _buildCollectionCard(
                                collectionName,
                                index,
                              ),
                            );
                          }, childCount: collections.length),
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionCard(String collectionName, int index) {
    // Generate some sample data based on the collection name
    const colors = [
      Color(0xFFFF5722),
      Color(0xFF9C27B0),
      Color(0xFF2196F3),
      Color(0xFF4CAF50),
    ];
    const icons = [
      Icons.temple_hindu,
      Icons.celebration,
      Icons.festival,
      Icons.emoji_events,
    ];

    final color = colors[index % colors.length];
    final icon = icons[index % icons.length];
    final totalExpenses = '₹${(15000 + (index * 5000))}';

    return GestureDetector(
      onTap: () => _openCollection(collectionName),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFCDD2).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _openCollection(collectionName),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // Card content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(icon, color: color, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    collectionName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E2E2E),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey[400],
                              size: 18,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Stats Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                'Total Collection',
                                totalExpenses,
                                Icons.money,
                                const Color(0xFF4CAF50),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildStatItem(
                                'Total Expenditure',
                                '₹65,454',
                                Icons.receipt_long,
                                const Color(0xFFFF5722),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
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
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E2E2E),
            ),
          ),
        ],
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
              Icons.temple_hindu,
              size: 80,
              color: const Color(0xFFFF5722).withOpacity(0.7),
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
            'Your festival collections will appear here\nonce they are set up',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
