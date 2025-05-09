import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udgaam/services/supabase_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrderHistory();
  }

  Future<void> _fetchOrderHistory() async {
    setState(() => isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated. Please log in.');
      }

      debugPrint('Fetching orders for user ID: ${user.id}');

      final response = await SupabaseService.client
          .from('orders')
          .select()
          .eq('user_id', user.id) // Only completed orders
          .order('created_at', ascending: false); // Newest first

      debugPrint('Orders fetched: $response');

      setState(() {
        orders = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to fetch order history: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load order history: $e')),
      );
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order History',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.green[800],
        elevation: 0,
      ),
      backgroundColor: Colors.grey[900],
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_toggle_off,
                          size: 60, color: Colors.grey[600]),
                      const SizedBox(height: 16),
                      Text(
                        'No Completed Orders',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchOrderHistory,
                  color: Colors.green,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final orderDateTime =
                          DateTime.parse(order['created_at']).toLocal();
                      final orderDate = orderDateTime
                          .toString()
                          .substring(0, 10); // YYYY-MM-DD
                      final orderTime =
                          orderDateTime.toString().substring(11, 16); // HH:MM
                      final orderItems =
                          List<Map<String, dynamic>>.from(order['order_items']);

                      return Card(
                        color: Colors.grey[850],
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    orderDate,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green[700],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      orderTime,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.grey, height: 24),
                              const Text(
                                'Items Purchased',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...orderItems.map(
                                (item) => Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, bottom: 8),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.local_grocery_store,
                                          size: 16, color: Colors.greenAccent),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${item['product_name']} - ${item['quantity']} ${item['unit']} @ ₹${item['price'].toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildDetailRow('Total Amount',
                                  '₹${order['total_amount'].toStringAsFixed(2)}'),
                              _buildDetailRow(
                                  'Payment Mode', order['payment_method']),
                              _buildDetailRow('Status', order['status']),
                              _buildDetailRow(
                                  'Address', order['delivery_address']),
                              _buildDetailRow('Phone', order['phone_number']),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
