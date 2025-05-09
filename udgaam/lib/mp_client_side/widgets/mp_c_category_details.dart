import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:udgaam/mp_client_side/controllers/cart_controller.dart';
import 'package:udgaam/mp_client_side/views/mp_c_cart_screen.dart';
import 'package:udgaam/mp_client_side/widgets/mp_c_userproductcard.dart';
import 'package:udgaam/services/supabase_service.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String categoryName;

  const CategoryDetailScreen({super.key, required this.categoryName});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;
  String? sortOption = 'Name';

  @override
  void initState() {
    super.initState();
    fetchProducts();
    if (!Get.isRegistered<CartController>()) {
      Get.put(CartController());
    }
  }

  Future<void> fetchProducts() async {
    try {
      var query = SupabaseService.client
          .from('products')
          .select(
              'product_id, product_name, image_url, price, description, id, unit')
          .eq('category', widget.categoryName);

      final sortedQuery = sortOption == 'Price'
          ? query.order('price', ascending: true)
          : query.order('product_name', ascending: true);

      final response = await sortedQuery;

      final productList = List<Map<String, dynamic>>.from(response);
      for (var product in productList) {
        try {
          final farmerResponse = await SupabaseService.client
              .from('users')
              .select('metadata')
              .eq('id', product['id'] ?? '')
              .maybeSingle();

          product['farmer_name'] =
              farmerResponse?['metadata']?['name'] ?? 'Unknown Farmer';
        } catch (e) {
          product['farmer_name'] = 'Unknown Farmer';
        }
      }

      setState(() {
        products = productList;
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
    final CartController cartController = Get.find<CartController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.green[700],
      ),
      backgroundColor: Colors.grey[850],
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.white),
                          filled: true,
                          fillColor: Colors.grey[900],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (value) {
                          // Add search logic here if needed
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: sortOption,
                      dropdownColor: Colors.grey[900],
                      style: const TextStyle(color: Colors.white),
                      items: ['Name', 'Price'].map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          sortOption = value;
                          isLoading = true;
                          fetchProducts();
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : products.isEmpty
                        ? const Center(
                            child: Text(
                              "No products found for this category.",
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
                                return UserProductCard(
                                  productId:
                                      product['product_id']?.toString() ??
                                          'N/A',
                                  imageUrl:
                                      product['image_url']?.toString() ?? '',
                                  productName:
                                      product['product_name']?.toString() ??
                                          'N/A',
                                  price: double.tryParse(
                                          product['price']?.toString() ??
                                              '0') ??
                                      0.0,
                                  description:
                                      product['description']?.toString() ??
                                          'No description',
                                  farmerName:
                                      product['farmer_name']?.toString() ??
                                          'Unknown',
                                  unit: product['unit']?.toString() ?? 'kg',
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
              child: Obx(
                () => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shopping_cart,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${cartController.cartItems.length} Item${cartController.cartItems.length != 1 ? 's' : ''}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
