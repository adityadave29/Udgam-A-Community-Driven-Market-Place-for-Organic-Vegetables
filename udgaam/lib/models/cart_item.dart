class CartItem {
  final String productId;
  final String productName;
  final String farmerName;
  final double price;
  final int quantity;
  final String unit;
  final String imageUrl;

  CartItem({
    required this.productId,
    required this.productName,
    required this.farmerName,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'farmer_name': farmerName,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'image_url': imageUrl,
    };
  }
}
