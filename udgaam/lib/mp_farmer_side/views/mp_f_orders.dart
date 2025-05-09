import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MpFOrders extends StatefulWidget {
  const MpFOrders({super.key});

  @override
  State<MpFOrders> createState() => _MpFOrdersState();
}

class _MpFOrdersState extends State<MpFOrders> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> farmerOrders = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchFarmerOrders();
  }

  Future<void> fetchFarmerOrders() async {
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

      // Step 2: Fetch orders from farmersordersdetail where farmer_id matches
      final ordersResponse = await supabase
          .from('farmersordersdetail')
          .select(
              'created_at, product_id, order_id, quantity, price, total_amount, user_id')
          .eq('farmer_id', farmerId)
          .order('created_at', ascending: false);

      List<Map<String, dynamic>> orders =
          List<Map<String, dynamic>>.from(ordersResponse);

      // Step 3: Enrich data with product name and user name
      for (var order in orders) {
        // Fetch product name from products table
        final productResponse = await supabase
            .from('products')
            .select('product_name')
            .eq('product_id', order['product_id'])
            .single();

        order['product_name'] =
            productResponse['product_name'] ?? 'Unknown Product';

        // Fetch user name from users table metadata
        final userResponse = await supabase
            .from('users')
            .select('metadata')
            .eq('id', order['user_id'])
            .single();

        final metadata = userResponse['metadata'] as Map<String, dynamic>?;
        order['user_name'] = metadata?['name'] ?? 'Unknown User';
      }

      setState(() {
        farmerOrders = orders;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.green))
            : error != null
                ? Center(
                    child: Text('Error: $error',
                        style: const TextStyle(color: Colors.red)))
                : farmerOrders.isEmpty
                    ? const Center(
                        child: Text('No orders found',
                            style: TextStyle(fontSize: 18)))
                    : RefreshIndicator(
                        onRefresh: fetchFarmerOrders,
                        child: ListView.builder(
                          itemCount: farmerOrders.length,
                          itemBuilder: (context, index) {
                            final order = farmerOrders[index];
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.green, // Green border
                                  width: 1.0, // Border size 1
                                ),
                                borderRadius: BorderRadius.circular(
                                    8), // Optional: rounded corners
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Card(
                                elevation: 2,
                                margin:
                                    EdgeInsets.zero, // Card fills the Container
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8), // Match Container
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Product: ${order['product_name']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Ordered At: ${order['created_at'].toString().substring(0, 19)}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        'Quantity: ${order['quantity']}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        'Price: ₹${order['price'].toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        'Total Amount: ₹${order['total_amount'].toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        'User: ${order['user_name']}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}
