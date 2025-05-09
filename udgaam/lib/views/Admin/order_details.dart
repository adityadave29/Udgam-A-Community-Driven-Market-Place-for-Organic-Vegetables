import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PendingOrdersWidget extends StatefulWidget {
  const PendingOrdersWidget({super.key});

  @override
  _PendingOrdersWidgetState createState() => _PendingOrdersWidgetState();
}

class _PendingOrdersWidgetState extends State<PendingOrdersWidget> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> pendingOrders = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchPendingOrders();
  }

  Future<void> fetchPendingOrders() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await supabase
          .from('orders')
          .select()
          .eq('status', 'Pending')
          .order('created_at', ascending: true);

      setState(() {
        pendingOrders = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> updateOrderStatus(
      String orderId, String newStatus, List<dynamic> orderItems) async {
    try {
      if (newStatus == 'Completed') {
        // Step 1: Check and update product quantities
        for (var item in orderItems) {
          final productId = item['product_id'] as String;
          final quantity = item['quantity'] as int;

          final productResponse = await supabase
              .from('products')
              .select('product_id, quantity_available, id')
              .eq('product_id', productId)
              .single();

          if (productResponse.isEmpty) {
            throw Exception('Product not found for product_id: $productId.');
          }

          final product = productResponse;
          final available = product['quantity_available'] as int;

          if (available < quantity) {
            throw Exception(
                'Insufficient quantity for ${item['product_name']} (Available: $available, Requested: $quantity)');
          }

          final newQuantity = available - quantity;
          await supabase.from('products').update(
              {'quantity_available': newQuantity}).eq('product_id', productId);
        }

        // Step 2: Fetch user_id from orders table
        final orderResponse = await supabase
            .from('orders')
            .select('user_id')
            .eq('id', orderId)
            .single();

        final userId = orderResponse['user_id'] as String;

        // Step 3: Insert into farmersordersdetail for each item
        for (var item in orderItems) {
          final productId = item['product_id'] as String;
          final quantity = item['quantity'] as int; // Extract quantity
          final price = (item['price'] as num).toDouble(); // Extract price
          final totalAmount = quantity * price; // Calculate total_amount

          final productResponse = await supabase
              .from('products')
              .select('id')
              .eq('product_id', productId)
              .single();

          final farmerId = productResponse['id'] as String;

          final insertData = {
            'farmer_id': farmerId,
            'user_id': userId,
            'order_id': orderId,
            'product_id': productId,
            'created_at': DateTime.now().toUtc().toIso8601String(),
            'quantity': quantity,
            'price': price,
            'total_amount': totalAmount,
          };

          print('Inserting into farmersordersdetail: $insertData');

          await supabase.from('farmersordersdetail').insert(insertData);
        }

        // Step 4: Update order status to Completed
        await supabase
            .from('orders')
            .update({'status': newStatus}).eq('id', orderId);
      } else {
        // For Rejected status, just update the order status
        await supabase
            .from('orders')
            .update({'status': newStatus}).eq('id', orderId);
      }

      await fetchPendingOrders();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order ${newStatus.toLowerCase()}')),
        );
      }
    } catch (e) {
      print('Error details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating order: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : error != null
              ? Center(
                  child: Text('Error: $error',
                      style: const TextStyle(color: Colors.white)))
              : pendingOrders.isEmpty
                  ? const Center(
                      child: Text('No pending orders found',
                          style: TextStyle(color: Colors.white)))
                  : RefreshIndicator(
                      onRefresh: fetchPendingOrders,
                      color: Colors.white,
                      child: ListView.builder(
                        itemCount: pendingOrders.length,
                        itemBuilder: (context, index) {
                          final order = pendingOrders[index];
                          final orderItems =
                              order['order_items'] as List<dynamic>;

                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.green, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Card(
                              color: Colors.grey[800],
                              margin: EdgeInsets.zero,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order Date: ${order['created_at'].toString().substring(0, 19)}',
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.white),
                                    ),
                                    Text(
                                      'Order #${order['id'].toString().substring(0, 8)}...',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Table(
                                      border: TableBorder.all(
                                          color: Colors.grey.shade700),
                                      columnWidths: const {
                                        0: FlexColumnWidth(2), // Product
                                        1: FlexColumnWidth(2), // Farmer
                                        2: FlexColumnWidth(2), // Product ID
                                        3: FlexColumnWidth(2), // Qty & Price
                                      },
                                      children: [
                                        TableRow(
                                          decoration: BoxDecoration(
                                              color: Colors.grey[700]),
                                          children: const [
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text('Product',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white)),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text('Farmer',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white)),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text('Product ID',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white)),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text('Qty & Price',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                        ...orderItems.map((item) => TableRow(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                      item['product_name'] ??
                                                          '',
                                                      style: const TextStyle(
                                                          color: Colors.white)),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                      item['farmer_name'] ?? '',
                                                      style: const TextStyle(
                                                          color: Colors.white)),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    '${item['product_id'].toString().substring(0, 8)}...',
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    '${item['quantity']} ${item['unit']}\n₹${(item['price'] as num).toStringAsFixed(2)}/unit',
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Total: ₹${order['total_amount'].toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                        'Address: ${order['delivery_address']}',
                                        style: const TextStyle(
                                            color: Colors.white)),
                                    const SizedBox(height: 8),
                                    Text('Phone: ${order['phone_number']}',
                                        style: const TextStyle(
                                            color: Colors.white)),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => updateOrderStatus(
                                              order['id'],
                                              'Completed',
                                              orderItems),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                          child: const Text('Accept',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => updateOrderStatus(
                                              order['id'],
                                              'Rejected',
                                              orderItems),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Text('Reject',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
