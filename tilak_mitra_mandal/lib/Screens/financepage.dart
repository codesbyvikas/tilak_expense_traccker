import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tilak_mitra_mandal/Screens/collectionspage.dart';
import 'package:tilak_mitra_mandal/Screens/expensespage.dart';
import 'package:tilak_mitra_mandal/api/collections_api.dart';
import 'package:tilak_mitra_mandal/api/expense_api.dart';

class CollectionDetailPage extends StatefulWidget {
  final String collectionName;
  const CollectionDetailPage({required this.collectionName});

  @override
  State<CollectionDetailPage> createState() => _CollectionDetailPageState();
}

class _CollectionDetailPageState extends State<CollectionDetailPage> {
  String? _token;
  bool _isLoading = true;

  // Financial data variables
  double _totalCollection = 0.0;
  double _totalExpenses = 0.0;
  double get _remainingBalance => _totalCollection - _totalExpenses;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      setState(() {
        _token = token;
      });

      if (token != null) {
        await _fetchFinancialData();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Authentication required. Please login again.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading authentication data';
      });
    }
  }

  Future<void> _fetchFinancialData() async {
    if (_token == null) {
      print('CollectionDetailPage: _fetchFinancialData - No token available');
      setState(() {
        _isLoading = false;
        _errorMessage = 'No authentication token';
      });
      return;
    }

    print(
      'CollectionDetailPage: _fetchFinancialData - Starting API calls for ${widget.collectionName}',
    );
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print(
        'CollectionDetailPage: Calling CollectionApi.getTotalCollections...',
      );
      final collectionsData = await CollectionApi.getTotalCollections(
        _token!,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('CollectionDetailPage: Collection API timeout');
          throw Exception('Collection API timeout after 15 seconds');
        },
      );
      print('CollectionDetailPage: Collections API response: $collectionsData');

      print('CollectionDetailPage: Calling ExpenseApi.getTotalExpenses...');
      final expensesData = await ExpenseApi.getTotalExpenses(_token!).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('CollectionDetailPage: Expense API timeout');
          throw Exception('Expense API timeout after 15 seconds');
        },
      );
      print('CollectionDetailPage: Expenses API response: $expensesData');

      if (mounted) {
        print('CollectionDetailPage: Processing API responses');
        setState(() {
          // Handle different possible response structures - same logic as homepage
          if (collectionsData is Map<String, dynamic>) {
            _totalCollection = _extractAmount(collectionsData, 'collections');
          } else {
            print(
              'CollectionDetailPage: Unexpected collections data type: ${collectionsData.runtimeType}',
            );
            _totalCollection = 0.0;
          }

          if (expensesData is Map<String, dynamic>) {
            _totalExpenses = _extractAmount(expensesData, 'expenses');
          } else {
            print(
              'CollectionDetailPage: Unexpected expenses data type: ${expensesData.runtimeType}',
            );
            _totalExpenses = 0.0;
          }

          _isLoading = false;
          _errorMessage = null;
        });

        print(
          'CollectionDetailPage: Final totals - Collections: $_totalCollection, Expenses: $_totalExpenses',
        );
      }
    } catch (e) {
      print('CollectionDetailPage: Error in _fetchFinancialData: $e');
      print('CollectionDetailPage: Error type: ${e.runtimeType}');

      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        await _handleAuthError();
      } else if (mounted) {
        setState(() {
          _isLoading = false;
          _totalCollection = 0.0;
          _totalExpenses = 0.0;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });

        // Show error to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load data: ${_errorMessage ?? 'Unknown error'}',
            ),
            backgroundColor: const Color(0xFFD32F2F),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _fetchFinancialData,
            ),
          ),
        );
      }
    }
  }

  double _extractAmount(Map<String, dynamic> data, String type) {
    print('CollectionDetailPage: Extracting amount from $type data: $data');

    // Try different possible field names - same logic as homepage
    final possibleFields = ['total', 'totalAmount', 'amount', 'sum'];

    for (final field in possibleFields) {
      if (data.containsKey(field) && data[field] != null) {
        final value = data[field];
        print(
          'CollectionDetailPage: Found $field = $value (${value.runtimeType})',
        );

        if (value is num) {
          return value.toDouble();
        } else if (value is String) {
          final parsed = double.tryParse(value);
          if (parsed != null) {
            print('CollectionDetailPage: Parsed string value: $parsed');
            return parsed;
          }
        }
      }
    }

    print(
      'CollectionDetailPage: No valid amount found in $type data, defaulting to 0.0',
    );
    return 0.0;
  }

  Future<void> _handleAuthError() async {
    // Clear invalid token
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    setState(() {
      _token = null;
      _isLoading = false;
      _errorMessage = 'Session expired. Please login again.';
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_token != null) {
      await _fetchFinancialData();
    } else {
      await _loadToken();
    }
  }

  void _navigateToCollections() {
    if (_token == null) {
      _showAuthError();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => CollectionsPage(
              collectionName: widget.collectionName,
              token: _token!,
            ),
      ),
    ).then((_) {
      // Refresh data when returning from collections page
      _refreshData();
    });
  }

  void _navigateToExpenses() {
    if (_token == null) {
      _showAuthError();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ExpensesPage(
              collectionName: widget.collectionName,
              token: _token!,
            ),
      ),
    ).then((_) {
      // Refresh data when returning from expenses page
      _refreshData();
    });
  }

  void _showAuthError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Authentication required. Please login again.'),
        backgroundColor: Color(0xFFD32F2F),
      ),
    );
  }

  String _formatCurrency(double amount) {
    // Use the same formatting logic as homepage
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF5722).withOpacity(0.1),
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
                    color: const Color(0xFFFF5722).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFFF5722),
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Loading Financial Data...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait while we fetch your data',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: const Color(0xFFFF5722),
        child: Stack(
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
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Custom App Bar with Gradient
                SliverAppBar(
                  expandedHeight: 200,
                  floating: false,
                  pinned: true,
                  backgroundColor: const Color(0xFFD32F2F),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      color: Colors.white,
                      onPressed: _refreshData,
                      tooltip: 'Refresh Data',
                    ),
                    IconButton(
                      icon: const Icon(Icons.bug_report),
                      color: Colors.white,
                      onPressed: () {
                        // Show debug info similar to homepage
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Debug Info'),
                                content: Text(
                                  'Collection: ${widget.collectionName}\n'
                                  'Token: ${_token != null ? 'Present' : 'Missing'}\n'
                                  'Loading: $_isLoading\n'
                                  'Collections: $_totalCollection\n'
                                  'Expenses: $_totalExpenses\n'
                                  'Balance: $_remainingBalance\n'
                                  'Error: ${_errorMessage ?? 'None'}',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                        );
                      },
                      tooltip: 'Debug Info',
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    titlePadding: const EdgeInsets.only(bottom: 16),
                    title: Text(
                      widget.collectionName,
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
                      // Error message if any
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD32F2F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFD32F2F).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFD32F2F),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Color(0xFFD32F2F),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _refreshData,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
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
                        _navigateToCollections,
                      ),
                      const SizedBox(height: 20),
                      _buildActionButton(
                        context,
                        'Expenses',
                        'Track money spent',
                        Icons.remove_circle_outline,
                        const Color(0xFFFF5722),
                        _navigateToExpenses,
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
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
                  _formatCurrency(_totalCollection),
                  Icons.trending_up,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Total Expenses',
                  _formatCurrency(_totalExpenses),
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
              color:
                  _remainingBalance >= 0
                      ? const Color(0xFF2196F3).withOpacity(0.05)
                      : const Color(0xFFD32F2F).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    _remainingBalance >= 0
                        ? const Color(0xFF2196F3).withOpacity(0.1)
                        : const Color(0xFFD32F2F).withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _remainingBalance >= 0
                          ? Icons.account_balance_wallet
                          : Icons.warning_amber_rounded,
                      color:
                          _remainingBalance >= 0
                              ? const Color(0xFF2196F3)
                              : const Color(0xFFD32F2F),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _remainingBalance >= 0 ? 'Remaining Balance' : 'Deficit',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _formatCurrency(_remainingBalance.abs()),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color:
                        _remainingBalance >= 0
                            ? const Color(0xFF2196F3)
                            : const Color(0xFFD32F2F),
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
