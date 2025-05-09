import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udgaam/models/cart_item.dart';
import 'package:udgaam/mp_client_side/controllers/cart_controller.dart';
import 'package:udgaam/mp_client_side/widgets/mp_c_success_screen.dart';
import 'package:udgaam/services/supabase_service.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final List<CartItem> cartItems;
  final String deliveryAddress;
  final String phoneNumber;

  const PaymentScreen({
    super.key,
    required this.totalAmount,
    required this.cartItems,
    required this.deliveryAddress,
    required this.phoneNumber,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isLoading = false;

  Future<void> _createOrder() async {
    setState(() => isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated. Please log in.');
      }

      debugPrint('Current authenticated user ID: ${user.id}');

      final orderData = {
        'user_id': user.id,
        'total_amount': widget.totalAmount,
        'delivery_address': widget.deliveryAddress,
        'phone_number': widget.phoneNumber,
        'order_items': widget.cartItems.map((item) => item.toJson()).toList(),
        'status': 'Pending',
        'payment_method': 'COD',
      };

      debugPrint('Inserting order: $orderData');

      // Insert into orders table and retrieve the inserted row
      final response = await SupabaseService.client
          .from('orders')
          .insert(orderData)
          .select()
          .single();

      debugPrint('Order inserted: $response');

      // Clear the cart
      Get.find<CartController>().clearCart();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')));

      // Navigate to SuccessScreen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SuccessScreen()),
        );
      }
    } catch (e) {
      debugPrint('Failed to insert order: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to place order: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _confirmCOD() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Confirm Cash on Delivery',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'You will pay ₹${widget.totalAmount.toStringAsFixed(2)} in cash upon delivery. Confirm?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close the dialog
              await _createOrder(); // Insert order and navigate
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.green[700],
      ),
      backgroundColor: Colors.grey[850],
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Amount: ₹${widget.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Payment Method',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.money, color: Colors.white),
                  title: const Text('Cash on Delivery',
                      style: TextStyle(color: Colors.white)),
                  tileColor: Colors.grey[900],
                  onTap: _confirmCOD,
                ),
              ],
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
