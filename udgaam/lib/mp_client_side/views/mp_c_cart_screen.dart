import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udgaam/models/user_model.dart';
import 'package:udgaam/mp_client_side/controllers/cart_controller.dart';
import 'package:udgaam/mp_client_side/views/mp_c_address.dart';
import 'package:udgaam/mp_client_side/views/mp_c_payment.dart';
import 'package:udgaam/services/supabase_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController cartController = Get.find<CartController>();
  UserModel? currentUser;
  bool isLoading = true;
  List<String> recommendedProductIds = [];
  List<Map<String, dynamic>> recommendedProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await SupabaseService.client
            .from('users')
            .select('email, metadata')
            .eq('id', user.id)
            .single();
        setState(() {
          currentUser = UserModel.fromJson(response);
          isLoading = false;
        });
        await _fetchRecommendations(user.id);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch user data: $e')),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchRecommendations(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.1.98.105:8000/recommend'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          recommendedProductIds = List<String>.from(data['product_ids']);
        });
        await _fetchRecommendedProductDetails();
      } else {
        throw Exception(
            'Failed to fetch recommendations: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching recommendations: $e')),
      );
    }
  }

  Future<void> _fetchRecommendedProductDetails() async {
    try {
      if (recommendedProductIds.isEmpty) return;
      final response = await SupabaseService.client
          .from('products')
          .select('product_id, product_name, price, image_url, unit')
          .inFilter('product_id', recommendedProductIds);
      setState(() {
        recommendedProducts = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch recommended products: $e')),
      );
    }
  }

  double _calculateCGST() => cartController.totalPrice * 0.09;
  double _calculateSGST() => cartController.totalPrice * 0.09;
  double _calculateTotalBill() =>
      cartController.totalPrice + _calculateCGST() + _calculateSGST();

  void _navigateToDeliveryDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeliveryDetailsScreen()),
    ).then((_) => _fetchUserData());
  }

  void _navigateToPayment() {
    if (currentUser?.metadata?.defaultAddress?.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please set a default address and phone number')),
      );
      _navigateToDeliveryDetails();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          totalAmount: _calculateTotalBill(),
          cartItems: cartController.cartItems,
          deliveryAddress: currentUser!.metadata!.defaultAddress!,
          phoneNumber: currentUser!.metadata!.defaultPhoneNumber!,
        ),
      ),
    );
  }

  void _addToCart(Map<String, dynamic> product) {
    cartController.addToCart(
      product['product_id'],
      product['product_name'] ?? 'Unnamed Product',
      (product['price'] ?? 0).toDouble(),
      1, // Default quantity
      product['unit'] ?? 'unit', // Use fetched unit or fallback
      'Unknown Farmer', // Fallback until farmerName source is clarified
      product['image_url'] ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: Colors.green[700],
      ),
      backgroundColor: Colors.grey[850],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Obx(
              () => cartController.cartItems.isEmpty
                  ? const Center(
                      child: Text(
                        'Your cart is empty.',
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(10),
                      children: [
                        // Cart Items
                        ...cartController.cartItems
                            .map((item) => Card(
                                  color: Colors.grey[900],
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            image: DecorationImage(
                                              image: item.imageUrl.isNotEmpty
                                                  ? NetworkImage(item.imageUrl)
                                                  : const AssetImage(
                                                          'assets/images/placeholder.jpg')
                                                      as ImageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.productName,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'From: ${item.farmerName}',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white70),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Price: ₹${item.price.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                'Quantity: ${item.quantity} ${item.unit}',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                'Total: ₹${(item.price * item.quantity).toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.green),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () {
                                            cartController
                                                .removeFromCart(item.productId);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                            .toList(),
                        // Recommended Products Section
                        const SizedBox(height: 20),
                        const Text(
                          'Recommended Products',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        if (recommendedProducts.isEmpty)
                          const Text(
                            'Loading recommendations...',
                            style:
                                TextStyle(fontSize: 14, color: Colors.white70),
                          )
                        else
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: recommendedProducts
                                  .map((product) => Card(
                                        color: Colors.grey[900],
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  image: DecorationImage(
                                                    image: product['image_url'] !=
                                                                null &&
                                                            product['image_url']
                                                                .toString()
                                                                .isNotEmpty
                                                        ? NetworkImage(product[
                                                            'image_url'])
                                                        : const AssetImage(
                                                                'assets/images/placeholder.jpg')
                                                            as ImageProvider,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                product['product_name'] ??
                                                    'Unnamed Product',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Price: ₹${(product['price'] ?? 0).toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 10),
                                              ElevatedButton(
                                                onPressed: () =>
                                                    _addToCart(product),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.green[700],
                                                  foregroundColor: Colors.white,
                                                  minimumSize:
                                                      const Size(100, 36),
                                                ),
                                                child:
                                                    const Text('Add to Cart'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        // Delivery Address
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Delivery Address:',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currentUser?.metadata?.defaultAddress
                                                ?.isEmpty ??
                                            true
                                        ? 'No default address set'
                                        : currentUser!
                                            .metadata!.defaultAddress!,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.white70),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _navigateToDeliveryDetails,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700],
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Change'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Contact Number
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Contact Number:',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currentUser?.metadata?.defaultPhoneNumber
                                                ?.isEmpty ??
                                            true
                                        ? 'No default phone number set'
                                        : currentUser!
                                            .metadata!.defaultPhoneNumber!,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _navigateToDeliveryDetails,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700],
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Change'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Bill Details
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bill Details',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Subtotal: ₹${cartController.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                            Text(
                              'CGST (9%): ₹${_calculateCGST().toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                            Text(
                              'SGST (9%): ₹${_calculateSGST().toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                            const Divider(color: Colors.white70),
                            Text(
                              'Total Bill: ₹${_calculateTotalBill().toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _navigateToPayment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700],
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 40),
                              ),
                              child: const Text('Proceed to Payment'),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
    );
  }
}
