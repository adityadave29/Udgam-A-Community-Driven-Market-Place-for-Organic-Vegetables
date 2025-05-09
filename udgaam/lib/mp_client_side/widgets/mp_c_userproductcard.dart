import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:udgaam/models/cart_item.dart';
import 'package:udgaam/mp_client_side/controllers/cart_controller.dart';

class UserProductCard extends StatefulWidget {
  final String productId;
  final String imageUrl;
  final String productName;
  final double price;
  final String description;
  final String farmerName;
  final String unit;

  const UserProductCard({
    super.key,
    required this.productId,
    required this.imageUrl,
    required this.productName,
    required this.price,
    required this.description,
    required this.farmerName,
    required this.unit,
  });

  @override
  _UserProductCardState createState() => _UserProductCardState();
}

class _UserProductCardState extends State<UserProductCard> {
  int selectedQuantity =
      0; // Base quantity selected from modal (e.g., 1, 2, 5, 10)
  int multiplier = 0; // Number of times the base quantity is added
  final CartController cartController = Get.find<CartController>();

  @override
  void initState() {
    super.initState();
    // Sync with cart items on initialization and updates
    ever(cartController.cartItems, (List<CartItem> items) {
      final item =
          items.firstWhereOrNull((item) => item.productId == widget.productId);
      if (mounted) {
        setState(() {
          if (item != null && item.quantity > 0) {
            selectedQuantity = item.quantity > 0 && multiplier > 0
                ? item.quantity ~/ multiplier
                : item.quantity;
            multiplier = item.quantity ~/ selectedQuantity;
          } else {
            multiplier = 0;
            selectedQuantity = 0;
          }
        });
      }
    });
  }

  void _showQuantitySelector(BuildContext context) {
    int? tempSelectedQuantity = selectedQuantity > 0 ? selectedQuantity : null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Bucket Size for ${widget.productName}',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [1, 2, 5, 10].map((qty) {
                      return RadioListTile<int>(
                        value: qty,
                        groupValue: tempSelectedQuantity,
                        onChanged: (value) {
                          setModalState(() {
                            tempSelectedQuantity = value;
                          });
                        },
                        title: Text(
                          '$qty ${widget.unit}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        activeColor: Colors.green[700],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: tempSelectedQuantity != null
                          ? () {
                              setState(() {
                                selectedQuantity = tempSelectedQuantity!;
                                multiplier = 1;
                                cartController.addToCart(
                                  widget.productId,
                                  widget.productName,
                                  widget.price,
                                  selectedQuantity,
                                  widget.unit,
                                  widget.farmerName,
                                  widget.imageUrl,
                                );
                              });
                              Navigator.pop(context);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[900],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                      ),
                      child: const Text('Add', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  int _getCartQuantity() {
    final item = cartController.cartItems
        .firstWhereOrNull((item) => item.productId == widget.productId);
    return item?.quantity ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.productName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'From: ${widget.farmerName}',
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.yellow, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        '4.5',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${widget.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.description,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    image: DecorationImage(
                      image: widget.imageUrl.isNotEmpty
                          ? NetworkImage(widget.imageUrl)
                          : const AssetImage('assets/images/placeholder.jpg')
                              as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -10,
                  child: multiplier == 0
                      ? ElevatedButton(
                          onPressed: () => _showQuantitySelector(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          child: const Text('Add'),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove,
                                  color: Colors.white, size: 20),
                              padding: const EdgeInsets.all(4),
                              onPressed: () {
                                setState(() {
                                  if (multiplier > 1) {
                                    multiplier--;
                                    cartController.addToCart(
                                      widget.productId,
                                      widget.productName,
                                      widget.price,
                                      -selectedQuantity,
                                      widget.unit,
                                      widget.farmerName,
                                      widget.imageUrl,
                                    );
                                  } else {
                                    multiplier = 0;
                                    cartController
                                        .removeFromCart(widget.productId);
                                  }
                                });
                              },
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green[700],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_getCartQuantity()}', // Use actual cart quantity
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add,
                                  color: Colors.white, size: 20),
                              padding: const EdgeInsets.all(4),
                              onPressed: () {
                                setState(() {
                                  if (multiplier == 0) {
                                    _showQuantitySelector(
                                        context); // Prompt for quantity if none selected
                                  } else {
                                    multiplier++;
                                    cartController.addToCart(
                                      widget.productId,
                                      widget.productName,
                                      widget.price,
                                      selectedQuantity,
                                      widget.unit,
                                      widget.farmerName,
                                      widget.imageUrl,
                                    );
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
