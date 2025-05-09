import 'package:flutter/material.dart';
import 'package:udgaam/mp_client_side/widgets/mp_c_category_details.dart';

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({super.key});

  // Define the categories with local asset images
  final List<Map<String, String>> categories = const [
    {
      'name': 'Vegetables',
      'image': 'assets/vegetables.png',
    },
    {
      'name': 'Fruits',
      'image': 'assets/fruits.png',
    },
    {
      'name': 'Grains',
      'image': 'assets/grains.png',
    },
    {
      'name': 'Pulses',
      'image': 'assets/pulses.png',
    },
    {
      'name': 'Herbs',
      'image': 'assets/herbs.png',
    },
    {
      'name': 'Dairy Products',
      'image': 'assets/dairy.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0), // Padding outside the container
      child: Container(
        height: 130, // Fixed height for the entire widget
        decoration: BoxDecoration(
          color: Colors.grey[900], // Blackish-grey background
          borderRadius: BorderRadius.circular(16.0), // Rounded corners
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryDetailScreen(
                        categoryName: categories[index]['name']!,
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(categories[index]['image']!),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) => const AssetImage(
                              'assets/images/placeholder.jpg'), // Fallback image
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      categories[index]['name']!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
