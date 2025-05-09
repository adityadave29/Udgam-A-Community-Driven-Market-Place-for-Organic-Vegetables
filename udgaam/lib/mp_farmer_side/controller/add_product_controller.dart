import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udgaam/utils/env.dart';

class AddProductController extends GetxController {
  Rx<File?> productImage = Rx<File?>(null);
  final ImagePicker picker = ImagePicker();

  final productNameController = TextEditingController();
  final categoryController = TextEditingController();
  final priceController = TextEditingController();
  final unitController = TextEditingController();
  final quantityController = TextEditingController();
  final descriptionController = TextEditingController();
  final harvestDateController = TextEditingController();
  final expiryDateController = TextEditingController();

  void pickProductImage() async {
    XFile? file = await picker.pickMedia();
    if (file != null) {
      File selectedFile = File(file.path);
      productImage.value = selectedFile;
    }
  }

  Future<void> storeProduct({
    required String userId,
    required String productName,
    required String category,
    required double price,
    required String unit,
    required int quantity,
    required String description,
    required String harvestDate,
    required String expiryDate,
  }) async {
    try {
      final supabase = Supabase.instance.client;

      String? imageUrl;
      if (productImage.value != null && productImage.value!.existsSync()) {
        final imagePath = "$userId/${productName.replaceAll(' ', '_')}.png";
        await supabase.storage.from(Env.s3Bucket).upload(
            imagePath, productImage.value!,
            fileOptions: const FileOptions(upsert: true));
        imageUrl = supabase.storage.from(Env.s3Bucket).getPublicUrl(imagePath);
      }

      await supabase.from('products').insert({
        'id': userId,
        'product_name': productName,
        'category': category,
        'price': price,
        'unit': unit,
        'quantity_available': quantity,
        'description': description,
        'harvest_date': harvestDate,
        'expiry_date': expiryDate,
        'image_url': imageUrl ?? '',
        'created_at': DateTime.now().toIso8601String(),
      });

      Get.snackbar('Success', 'Product added successfully!',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
      dispose();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add product: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  Future<void> updateProduct({
    required String productId,
    required String userId,
    required double price,
    required int quantity,
    required String description,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final currentDate =
          DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD format

      await supabase.from('products').update({
        'price': price,
        'quantity_available': quantity,
        'description': description,
        'updated_at': currentDate,
      }).eq('product_id', productId);

      Get.snackbar('Success', 'Product updated successfully!',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
      Navigator.of(Get.context!).pop(); // Navigate to listed products
    } catch (e) {
      Get.snackbar('Error', 'Failed to update product: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  @override
  void onClose() {
    productImage.value = null;
    productNameController.dispose();
    categoryController.dispose();
    priceController.dispose();
    unitController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
    harvestDateController.dispose();
    expiryDateController.dispose();
    super.onClose();
  }
}
