import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:udgaam/controllers/post_controller.dart';
import 'package:udgaam/services/supabase_service.dart';
import 'package:udgaam/widgets/add_post_appbar.dart';
import 'package:udgaam/widgets/image_circle.dart';
import 'package:udgaam/widgets/post_image_preview.dart';

class AddPost extends StatelessWidget {
  AddPost({super.key});

  final SupabaseService supabaseService = Get.find<SupabaseService>();
  final PostController controller = Get.put(PostController());

  // Updated categories map (Hindi for display, English for storage)
  final Map<String, String> categories = {
    'सभी': 'General',
    'फसल प्रबंधन': 'Crop Management',
    'मौसम और जलवायु': 'Weather & Climate',
    'कृषि उपकरण और तकनीक': 'Farming Equipment & Technology',
    'बाजार और मूल्य': 'Market & Pricing',
    'पशुपालन': 'Animal Husbandry',
    'अन्य': 'Other'
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AddPostAppBar(),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: CircleImage(
                        url: supabaseService
                            .currentUser.value!.userMetadata?["image"],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: context.width * 0.80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            supabaseService
                                .currentUser.value!.userMetadata?["name"],
                          ),
                        ),
                        TextField(
                          autofocus: true,
                          controller: controller.textEditingController,
                          onChanged: (value) =>
                              controller.content.value = value,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 10,
                          minLines: 1,
                          maxLength: 1000,
                          decoration: const InputDecoration(
                            hintText: "Write a caption",
                            border: InputBorder.none,
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => controller.pickImage(),
                          child: Icon(Icons.attach_file_rounded),
                        ),
                        SizedBox(
                            height: 15), // Space between attach file & category
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Category",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 5),
                            Obx(
                              () => Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: categories.keys.contains(
                                            controller.selectedCategory.value)
                                        ? controller.selectedCategory.value
                                        : categories.keys
                                            .first, // Default to first item if invalid
                                    icon: Icon(Icons.arrow_drop_down),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        controller.selectedCategory.value =
                                            newValue;
                                      }
                                    },
                                    items: categories.keys.map((String key) {
                                      return DropdownMenuItem<String>(
                                        value: key,
                                        child: Text(key),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Obx(
                          () => Column(
                            children: [
                              if (controller.image.value != null)
                                PostImagePreview(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
