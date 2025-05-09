import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udgaam/models/cart_item.dart';

class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;
  final supabase = Supabase.instance.client;

  double get totalPrice =>
      cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  int get totalQuantity =>
      cartItems.fold(0, (sum, item) => sum + item.quantity);

  Future<void> addToCart(
    String productId,
    String productName,
    double price,
    int quantity,
    String unit,
    String farmerName,
    String imageUrl,
  ) async {
    try {
      // Fetch available quantity from products table
      final productResponse = await supabase
          .from('products')
          .select('quantity_available')
          .eq('product_id',
              productId); // Using product_id as per your previous context

      if (productResponse.isEmpty) {
        Get.snackbar(
          'Error',
          'Product not found in inventory',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final availableQuantity = productResponse[0]['quantity_available'] as int;
      print('Available quantity for $productId: $availableQuantity');

      // Check if the product already exists in the cart
      final existingItemIndex =
          cartItems.indexWhere((item) => item.productId == productId);
      int totalRequestedQuantity = quantity;

      if (existingItemIndex != -1) {
        // If item exists, calculate total requested quantity including current cart amount
        totalRequestedQuantity =
            cartItems[existingItemIndex].quantity + quantity;
      }

      // Check if requested quantity exceeds available quantity
      if (totalRequestedQuantity > availableQuantity) {
        Get.snackbar(
          'Insufficient Stock',
          'Only $availableQuantity $unit of $productName available',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // If quantity is available, proceed with adding/updating cart silently
      if (existingItemIndex != -1) {
        // Update existing item
        final existingItem = cartItems[existingItemIndex];
        cartItems[existingItemIndex] = CartItem(
          productId: existingItem.productId,
          productName: existingItem.productName,
          farmerName: existingItem.farmerName,
          price: existingItem.price,
          quantity: totalRequestedQuantity,
          unit: existingItem.unit,
          imageUrl: existingItem.imageUrl,
        );
      } else {
        // Add new item
        cartItems.add(CartItem(
          productId: productId,
          productName: productName,
          farmerName: farmerName,
          price: price,
          quantity: quantity,
          unit: unit,
          imageUrl: imageUrl,
        ));
      }
      // Removed success snackbar
    } catch (e) {
      print('Error checking quantity: $e');
      Get.snackbar(
        'Error',
        'Failed to add product to cart: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void removeFromCart(String productId) {
    cartItems.removeWhere((item) => item.productId == productId);
  }

  void clearCart() {
    cartItems.clear();
  }
}
