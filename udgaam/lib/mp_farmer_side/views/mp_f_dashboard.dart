import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udgaam/mp_farmer_side/views/mp_f_insights.dart';
import 'package:udgaam/mp_farmer_side/views/mp_f_time_series_page.dart';

class MpFDashboard extends StatefulWidget {
  const MpFDashboard({super.key});

  @override
  State<MpFDashboard> createState() => _MpFDashboardState();
}

class _MpFDashboardState extends State<MpFDashboard> {
  final supabase = Supabase.instance.client;
  int ordersToday = 0;
  int ordersThisMonth = 0;
  int ordersThisYear = 0;
  double revenueToday = 0.0;
  double revenueThisMonth = 0.0;
  double revenueThisYear = 0.0;
  String topSellerToday = 'N/A';
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Step 1: Get current logged-in farmer's ID
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently logged in.');
      }
      final farmerId = user.id;

      // Step 2: Define time periods (assuming today is April 4, 2025)
      final now = DateTime.now().toUtc(); // Current date: April 4, 2025
      final todayStart = DateTime(now.year, now.month, now.day).toUtc();
      final todayEnd = todayStart.add(const Duration(days: 1));
      final monthStart = DateTime(now.year, now.month, 1).toUtc();
      final yearStart = DateTime(now.year, 1, 1).toUtc();

      // Step 3: Fetch all orders for the farmer
      final ordersResponse = await supabase
          .from('farmersordersdetail')
          .select('created_at, product_id, total_amount')
          .eq('farmer_id', farmerId);

      List<Map<String, dynamic>> orders =
          List<Map<String, dynamic>>.from(ordersResponse);

      // Step 4: Calculate stats
      final todayOrders = orders.where((order) {
        final createdAt = DateTime.parse(order['created_at']);
        return createdAt.isAfter(todayStart) && createdAt.isBefore(todayEnd);
      }).toList();

      final monthOrders = orders.where((order) {
        final createdAt = DateTime.parse(order['created_at']);
        return createdAt.isAfter(monthStart);
      }).toList();

      final yearOrders = orders.where((order) {
        final createdAt = DateTime.parse(order['created_at']);
        return createdAt.isAfter(yearStart);
      }).toList();

      // Order counts
      ordersToday = todayOrders.length;
      ordersThisMonth = monthOrders.length;
      ordersThisYear = yearOrders.length;

      // Revenue calculations
      revenueToday = todayOrders.fold(
          0.0, (sum, order) => sum + (order['total_amount'] as num).toDouble());
      revenueThisMonth = monthOrders.fold(
          0.0, (sum, order) => sum + (order['total_amount'] as num).toDouble());
      revenueThisYear = yearOrders.fold(
          0.0, (sum, order) => sum + (order['total_amount'] as num).toDouble());

      // Step 5: Find top seller for today
      if (todayOrders.isNotEmpty) {
        final productRevenueMap = <String, double>{};
        for (var order in todayOrders) {
          final productId = order['product_id'] as String;
          final amount = (order['total_amount'] as num).toDouble();
          productRevenueMap[productId] =
              (productRevenueMap[productId] ?? 0) + amount;
        }

        final topProductEntry = productRevenueMap.entries.reduce((a, b) =>
            a.value > b.value ? a : b); // Find entry with highest revenue
        final topProductId = topProductEntry.key;

        final productResponse = await supabase
            .from('products')
            .select('product_name')
            .eq('product_id', topProductId)
            .single();

        topSellerToday = productResponse['product_name'] ?? 'Unknown Product';
      } else {
        topSellerToday = 'No Sales Today';
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      print('Error fetching dashboard data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Farmer Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[700],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green))
                : error != null
                    ? Center(
                        child: Text('Error: $error',
                            style: const TextStyle(color: Colors.red)))
                    : RefreshIndicator(
                        onRefresh: fetchDashboardData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Order Statistics',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatCard('Orders Today', '$ordersToday',
                                      Colors.blue[700]!),
                                  _buildStatCard('Orders This Month',
                                      '$ordersThisMonth', Colors.blue[700]!),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatCard('Orders This Year',
                                      '$ordersThisYear', Colors.blue[700]!),
                                  _buildStatCard('Top Seller Today',
                                      topSellerToday, Colors.green[700]!),
                                ],
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Revenue Statistics',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatCard(
                                      'Revenue Today',
                                      '₹${revenueToday.toStringAsFixed(2)}',
                                      Colors.green[700]!),
                                  _buildStatCard(
                                      'Revenue This Month',
                                      '₹${revenueThisMonth.toStringAsFixed(2)}',
                                      Colors.green[700]!),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildStatCard(
                                  'Revenue This Year',
                                  '₹${revenueThisYear.toStringAsFixed(2)}',
                                  Colors.green[700]!),
                            ],
                          ),
                        ),
                      ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Insights()),
                );
              },
              label: const Text('Insights'),
              icon: const Icon(Icons.insights),
              backgroundColor: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      color: Colors.grey[900],
      elevation: 4,
      child: SizedBox(
        width: 160,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
