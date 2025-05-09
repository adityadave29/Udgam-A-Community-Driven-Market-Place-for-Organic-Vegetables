import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:udgaam/mp_farmer_side/controller/add_product_controller.dart';

class EditProductScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const EditProductScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddProductController());

    controller.priceController.text = product['price'].toString();
    controller.quantityController.text =
        product['quantity_available'].toString();
    controller.descriptionController.text = product['description'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        backgroundColor: Colors.grey[900],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product['image_url'] ?? '',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                  size: 100,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Product: ${product['product_name']}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller.priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: controller.quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: controller.descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                controller.updateProduct(
                  productId: product['product_id'],
                  userId: product['id'],
                  price: double.parse(controller.priceController.text),
                  quantity: int.parse(controller.quantityController.text),
                  description: controller.descriptionController.text,
                );
              },
              child: const Text('Update Product'),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[850],
    );
  }
}
