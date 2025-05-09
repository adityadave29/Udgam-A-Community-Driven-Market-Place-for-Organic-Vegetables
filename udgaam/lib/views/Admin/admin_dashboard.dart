import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:udgaam/services/supabase_service.dart';

class AdminDashboardHome extends StatefulWidget {
  const AdminDashboardHome({super.key});

  @override
  State<AdminDashboardHome> createState() => _AdminDashboardHomeState();
}

class _AdminDashboardHomeState extends State<AdminDashboardHome> {
  int approvedCount = 0;
  int rejectedCount = 0;
  int pendingCount = 0;
  int ordersToday = 0;
  int ordersThisMonth = 0;
  int ordersThisYear = 0;
  double avgOrdersPerDay = 0.0;
  double rejectionRatio = 0.0;
  double acceptanceRatio = 0.0;
  List<int> monthlyOrders = List.filled(12, 0); // April 2025 to March 2026
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    await fetchFarmerCounts();
    await fetchOrderStats();
    setState(() => isLoading = false);
  }

  Future<void> fetchFarmerCounts() async {
    try {
      final response =
          await SupabaseService.client.from('farmerreg').select('status');
      final List<dynamic> farmers = response as List<dynamic>;
      setState(() {
        approvedCount = farmers.where((f) => f['status'] == 'Approved').length;
        rejectedCount = farmers.where((f) => f['status'] == 'Rejected').length;
        pendingCount = farmers.where((f) => f['status'] == 'Pending').length;
      });
    } catch (e) {
      debugPrint('Error fetching farmer counts: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load farmer counts: $e')),
      );
    }
  }

  Future<void> fetchOrderStats() async {
    try {
      final now = DateTime.now(); // April 04, 2025
      final todayStart = DateTime(now.year, now.month, now.day);
      final monthStart = DateTime(now.year, now.month, 1);
      final calendarYearStart = DateTime(now.year, 1, 1);
      final fiscalYearStart2025 = DateTime(2025, 4, 1); // April 1, 2025
      final fiscalYearEnd2026 =
          DateTime(2026, 3, 31, 23, 59, 59); // March 31, 2026

      final response = await SupabaseService.client
          .from('orders')
          .select('created_at, status')
          .gte('created_at', fiscalYearStart2025.toIso8601String())
          .lte('created_at', fiscalYearEnd2026.toIso8601String());

      final List<dynamic> orders = response as List<dynamic>;

      setState(() {
        ordersToday = orders
            .where((order) =>
                DateTime.parse(order['created_at']).isAfter(todayStart))
            .length;
        ordersThisMonth = orders
            .where((order) =>
                DateTime.parse(order['created_at']).isAfter(monthStart))
            .length;
        ordersThisYear = orders
            .where((order) =>
                DateTime.parse(order['created_at']).isAfter(calendarYearStart))
            .length;
        final daysInYear = now.difference(calendarYearStart).inDays + 1;
        avgOrdersPerDay = ordersThisYear / daysInYear;

        final completedOrders =
            orders.where((o) => o['status'] == 'Completed').length;
        final rejectedOrders =
            orders.where((o) => o['status'] == 'Rejected').length;
        final totalDecidedOrders = completedOrders + rejectedOrders;
        if (totalDecidedOrders > 0) {
          acceptanceRatio = (completedOrders / totalDecidedOrders) * 100;
          rejectionRatio = (rejectedOrders / totalDecidedOrders) * 100;
        }

        // Monthly Orders (April 2025 to March 2026)
        monthlyOrders = List.filled(12, 0); // Reset to ensure clean slate
        for (var order in orders) {
          final createdAt = DateTime.parse(order['created_at']);
          if (createdAt.isAfter(fiscalYearStart2025) &&
              createdAt
                  .isBefore(fiscalYearEnd2026.add(const Duration(days: 1)))) {
            final monthIndex =
                (createdAt.month - 4 + (createdAt.year - 2025) * 12) % 12;
            monthlyOrders[monthIndex]++;
          }
        }
      });
    } catch (e) {
      debugPrint('Error fetching order stats: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load order stats: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: fetchData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Farmer Statistics',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard('Approved Farmers', '$approvedCount',
                              Colors.green[700]!),
                          _buildStatCard('Rejected Farmers', '$rejectedCount',
                              Colors.red[700]!),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildStatCard('Pending Farmers', '$pendingCount',
                          Colors.orange[700]!),
                      const SizedBox(height: 24),
                      const Text(
                        'Order Statistics (FY 2025-26)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard('Orders Today', '$ordersToday',
                              Colors.blue[700]!),
                          _buildStatCard('Orders This Month',
                              '$ordersThisMonth', Colors.blue[700]!),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard('Orders This Year (Calendar)',
                              '$ordersThisYear', Colors.blue[700]!),
                          _buildStatCard(
                              'Avg Orders/Day (Calendar)',
                              avgOrdersPerDay.toStringAsFixed(2),
                              Colors.blue[700]!),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard(
                              'Acceptance Ratio',
                              '${acceptanceRatio.toStringAsFixed(1)}%',
                              Colors.green[700]!),
                          _buildStatCard(
                              'Rejection Ratio',
                              '${rejectionRatio.toStringAsFixed(1)}%',
                              Colors.red[700]!),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Monthly Sales (Apr 2025 - Mar 2026)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY:
                                (monthlyOrders.reduce((a, b) => a > b ? a : b) *
                                        1.2)
                                    .toDouble(),
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipItem:
                                    (group, groupIndex, rod, rodIndex) {
                                  final monthNames = [
                                    'Apr',
                                    'May',
                                    'Jun',
                                    'Jul',
                                    'Aug',
                                    'Sep',
                                    'Oct',
                                    'Nov',
                                    'Dec',
                                    'Jan',
                                    'Feb',
                                    'Mar'
                                  ];
                                  return BarTooltipItem(
                                    '${monthNames[group.x]}: ${rod.toY.toInt()}',
                                    const TextStyle(color: Colors.white),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const monthNames = [
                                      'Apr',
                                      'May',
                                      'Jun',
                                      'Jul',
                                      'Aug',
                                      'Sep',
                                      'Oct',
                                      'Nov',
                                      'Dec',
                                      'Jan',
                                      'Feb',
                                      'Mar'
                                    ];
                                    return Text(
                                      monthNames[value.toInt()],
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 12),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) => Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                  ),
                                ),
                              ),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(12, (index) {
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: monthlyOrders[index].toDouble(),
                                    color: Colors.blue[700],
                                    width: 16,
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                  fontSize: 24, // Reduced from 28
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
                style: const TextStyle(
                    fontSize: 12, color: Colors.white70), // Reduced from 14
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
