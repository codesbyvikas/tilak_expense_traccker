// homepage.dart
import 'package:flutter/material.dart';
import 'package:tilak_mitra_mandal/Screens/financepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tilak_mitra_mandal/Screens/loginpage.dart';
import 'package:tilak_mitra_mandal/api/collections_api.dart';
import 'package:tilak_mitra_mandal/api/expense_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> collections = ['Ganesh Chaturthi 2025'];

  // Variables to store totals
  double totalCollections = 0.0;
  double totalExpenses = 0.0;
  bool isLoading = true;
  String? token;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    print('HomeScreen: initState called');
    _initializeData();
  }

  Future<void> _initializeData() async {
    print('HomeScreen: _initializeData started');
    try {
      await _getToken();
      print('HomeScreen: Token retrieved: ${token != null ? 'Yes' : 'No'}');
      if (token != null) {
        print('HomeScreen: Token value: ${token!.substring(0, 20)}...');
        await _fetchTotals();
      } else {
        print('HomeScreen: No token found - stopping loading');
        setState(() {
          isLoading = false;
          errorMessage = 'No authentication token found. Please login again.';
        });
      }
    } catch (e) {
      print('HomeScreen: Error during initialization: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Initialization failed: $e';
      });
    }
  }

  Future<void> _getToken() async {
    print('HomeScreen: Getting token from SharedPreferences');
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_token');
    print(
      'HomeScreen: Token from prefs: ${token != null ? 'Found' : 'Not found'}',
    );
  }

  Future<void> _fetchTotals() async {
    if (token == null) {
      print('HomeScreen: _fetchTotals - No token available');
      setState(() {
        isLoading = false;
        errorMessage = 'No authentication token';
      });
      return;
    }

    print('HomeScreen: _fetchTotals - Starting API calls');
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('HomeScreen: About to call both APIs concurrently');

      // Test individual API calls first
      print('HomeScreen: Calling CollectionApi.getTotalCollections...');
      final collectionsData = await CollectionApi.getTotalCollections(
        token!,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('HomeScreen: Collection API timeout');
          throw Exception('Collection API timeout after 15 seconds');
        },
      );
      print('HomeScreen: Collections API response: $collectionsData');

      print('HomeScreen: Calling ExpenseApi.getTotalExpenses...');
      final expensesData = await ExpenseApi.getTotalExpenses(token!).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('HomeScreen: Expense API timeout');
          throw Exception('Expense API timeout after 15 seconds');
        },
      );
      print('HomeScreen: Expenses API response: $expensesData');

      if (mounted) {
        print('HomeScreen: Processing API responses');
        setState(() {
          // Handle different possible response structures
          if (collectionsData is Map<String, dynamic>) {
            totalCollections = _extractAmount(collectionsData, 'collections');
          } else {
            print(
              'HomeScreen: Unexpected collections data type: ${collectionsData.runtimeType}',
            );
            totalCollections = 0.0;
          }

          if (expensesData is Map<String, dynamic>) {
            totalExpenses = _extractAmount(expensesData, 'expenses');
          } else {
            print(
              'HomeScreen: Unexpected expenses data type: ${expensesData.runtimeType}',
            );
            totalExpenses = 0.0;
          }

          isLoading = false;
          errorMessage = null;
        });

        print(
          'HomeScreen: Final totals - Collections: $totalCollections, Expenses: $totalExpenses',
        );
      }
    } catch (e) {
      print('HomeScreen: Error in _fetchTotals: $e');
      print('HomeScreen: Error type: ${e.runtimeType}');

      if (mounted) {
        setState(() {
          isLoading = false;
          totalCollections = 0.0;
          totalExpenses = 0.0;
          errorMessage = e.toString().replaceAll('Exception: ', '');
        });

        // Show error to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load data: ${errorMessage ?? 'Unknown error'}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _fetchTotals,
            ),
          ),
        );
      }
    }
  }

  double _extractAmount(Map<String, dynamic> data, String type) {
    print('HomeScreen: Extracting amount from $type data: $data');

    // Try different possible field names
    final possibleFields = ['total', 'totalAmount', 'amount', 'sum'];

    for (final field in possibleFields) {
      if (data.containsKey(field) && data[field] != null) {
        final value = data[field];
        print('HomeScreen: Found $field = $value (${value.runtimeType})');

        if (value is num) {
          return value.toDouble();
        } else if (value is String) {
          final parsed = double.tryParse(value);
          if (parsed != null) {
            print('HomeScreen: Parsed string value: $parsed');
            return parsed;
          }
        }
      }
    }

    print('HomeScreen: No valid amount found in $type data, defaulting to 0.0');
    return 0.0;
  }

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

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '₹${amount.toStringAsFixed(0)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: RefreshIndicator(
        onRefresh: _fetchTotals,
        child: Stack(
          children: [
            // Background decorative elements
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
                      icon: const Icon(Icons.refresh),
                      color: Colors.white,
                      onPressed: _fetchTotals,
                      tooltip: 'Refresh Data',
                    ),
                    // IconButton(
                    //   icon: const Icon(Icons.bug_report),
                    //   color: Colors.white,
                    //   onPressed: () {
                    //     // Show debug info
                    //     showDialog(
                    //       context: context,
                    //       builder:
                    //           (context) => AlertDialog(
                    //             title: const Text('Debug Info'),
                    //             content: Text(
                    //               'Token: ${token != null ? 'Present' : 'Missing'}\n'
                    //               'Loading: $isLoading\n'
                    //               'Collections: $totalCollections\n'
                    //               'Expenses: $totalExpenses\n'
                    //               'Error: ${errorMessage ?? 'None'}',
                    //             ),
                    //             actions: [
                    //               TextButton(
                    //                 onPressed: () => Navigator.pop(context),
                    //                 child: const Text('Close'),
                    //               ),
                    //             ],
                    //           ),
                    //     );
                    //   },
                    //   tooltip: 'Debug Info',
                    // ),
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
                                  'तिलक मित्र मंडल',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
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

                // Error message banner
                if (errorMessage != null)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade600),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                          TextButton(
                            onPressed: _fetchTotals,
                            child: const Text('Retry'),
                          ),
                        ],
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
                                  Text(
                                    isLoading
                                        ? 'Loading data...'
                                        : 'Tap to view details',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
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
                                isLoading
                                    ? '...'
                                    : _formatCurrency(totalCollections),
                                Icons.money,
                                const Color(0xFF4CAF50),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildStatItem(
                                'Total Expenditure',
                                isLoading
                                    ? '...'
                                    : _formatCurrency(totalExpenses),
                                Icons.receipt_long,
                                const Color(0xFFFF5722),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Balance indicator
                        if (!isLoading) _buildBalanceIndicator(),
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

  Widget _buildBalanceIndicator() {
    final balance = totalCollections - totalExpenses;
    final isPositive = balance >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:
            isPositive
                ? const Color(0xFF4CAF50).withOpacity(0.1)
                : const Color(0xFFFF5722).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isPositive
                  ? const Color(0xFF4CAF50).withOpacity(0.3)
                  : const Color(0xFFFF5722).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            size: 16,
            color:
                isPositive ? const Color(0xFF4CAF50) : const Color(0xFFFF5722),
          ),
          const SizedBox(width: 6),
          Text(
            '${isPositive ? 'Surplus' : 'Deficit'}: ${_formatCurrency(balance.abs())}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color:
                  isPositive
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF5722),
            ),
          ),
        ],
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
          Row(
            children: [
              if (isLoading && value == '...')
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              else
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                ),
            ],
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
