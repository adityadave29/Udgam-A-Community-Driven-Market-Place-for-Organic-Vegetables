import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategorySelector extends StatelessWidget {
  final List<String> categories;
  final RxString selectedCategory;

  CategorySelector(
      {super.key, required this.categories, required this.selectedCategory});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Obx(() => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ChoiceChip(
                  label: Text(category),
                  selected: selectedCategory.value == category,
                  onSelected: (bool selected) {
                    if (selected) selectedCategory.value = category;
                  },
                  selectedColor: Colors.green.shade300,
                  backgroundColor: Colors.grey.shade200,
                ),
              ));
        },
      ),
    );
  }
}
