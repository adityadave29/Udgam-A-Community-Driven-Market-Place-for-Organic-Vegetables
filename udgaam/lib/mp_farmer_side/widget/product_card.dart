import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udgaam/mp_farmer_side/widget/edit_product_details.dart';
import 'package:udgaam/widgets/confirm_dialogue.dart';

class ProductDetailsCard extends StatelessWidget {
  final String productName;
  final String productId;
  final String createdAt;
  final String category;
  final double price;
  final int quantityAvailable;
  final String description;
  final String imageUrl;
  final String expiryDate;
  final String updatedAt;
  final String unit;

  const ProductDetailsCard({
    super.key,
    required this.productName,
    required this.productId,
    required this.createdAt,
    required this.category,
    required this.price,
    required this.quantityAvailable,
    required this.description,
    required this.imageUrl,
    required this.expiryDate,
    required this.updatedAt,
    required this.unit,
  });

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateString);
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _deleteProduct() async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('products').delete().eq('product_id', productId);
      Get.snackbar('Success', 'Product deleted successfully!',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete product: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                  size: 100,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailColumn("Product Name", productName),
                _buildDetailColumn("Category", category),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailColumn("Price", "₹ $price"),
                _buildDetailColumn("Quantity", "$quantityAvailable $unit"),
              ],
            ),
            const SizedBox(height: 10),
            _buildDetailColumn("Description", description),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailColumn("Harvest Date", _formatDate(createdAt)),
                _buildDetailColumn("Expiry Date", _formatDate(expiryDate)),
              ],
            ),
            const SizedBox(height: 10),
            _buildDetailColumn("Last Updated", _formatDate(updatedAt)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    Get.to(() => EditProductScreen(product: {
                          'product_id': productId,
                          'id': '', // Pass actual user ID if available
                          'product_name': productName,
                          'category': category,
                          'price': price,
                          'unit': unit,
                          'quantity_available': quantityAvailable,
                          'description': description,
                          'created_at': createdAt,
                          'expiry_date': expiryDate,
                          'image_url': imageUrl,
                        }));
                  },
                  icon: const Icon(Icons.edit, color: Colors.white),
                ),
                IconButton(
                  onPressed: () {
                    Get.dialog(
                      ConfirmDialogue(
                        title: "Delete Product",
                        text: "Are you sure you want to delete $productName?",
                        callback: () async {
                          await _deleteProduct();
                          Get.back(); // Close dialog
                          // Refresh the parent screen by popping back to it
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 150,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
