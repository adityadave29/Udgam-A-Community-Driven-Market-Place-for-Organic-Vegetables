import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:udgaam/mp_farmer_side/widget/product_card.dart';
import 'package:udgaam/services/supabase_service.dart';

class MpFListedProducts extends StatefulWidget {
  const MpFListedProducts({super.key});

  @override
  State<MpFListedProducts> createState() => _MpFListedProductsState();
}

class _MpFListedProductsState extends State<MpFListedProducts> {
  final SupabaseService supabaseService = Get.find<SupabaseService>();
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final userId = supabaseService.currentUser.value?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final response = await SupabaseService.client
          .from('products')
          .select('*')
          .eq('id', userId);

      setState(() {
        products = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listed Products"),
        backgroundColor: Colors.grey[900],
      ),
      backgroundColor: Colors.grey[850],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(
                  child: Text(
                    "No products listed yet.",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchProducts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductDetailsCard(
                        productName:
                            product['product_name']?.toString() ?? 'N/A',
                        productId: product['product_id']?.toString() ?? 'N/A',
                        createdAt: product['created_at']?.toString() ?? 'N/A',
                        category: product['category']?.toString() ?? 'N/A',
                        unit: product['unit']?.toString() ?? '',
                        price: double.tryParse(
                                product['price']?.toString() ?? '0') ??
                            0.0,
                        quantityAvailable: int.tryParse(
                                product['quantity_available']?.toString() ??
                                    '0') ??
                            0,
                        description:
                            product['description']?.toString() ?? 'N/A',
                        imageUrl: product['image_url']?.toString() ?? '',
                        expiryDate: product['expiry_date']?.toString() ?? 'N/A',
                        updatedAt: product['updated_at']?.toString() ?? 'N/A',
                      );
                    },
                  ),
                ),
    );
  }
}
