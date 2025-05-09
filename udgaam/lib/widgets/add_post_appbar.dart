import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:udgaam/controllers/post_controller.dart';
import 'package:udgaam/services/supabase_service.dart';

class AddPostAppBar extends StatefulWidget {
  AddPostAppBar({super.key});

  @override
  State<AddPostAppBar> createState() => _AddPostAppBarState();
}

class _AddPostAppBarState extends State<AddPostAppBar> {
  final PostController controller = Get.find<PostController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xff242424),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const SizedBox(width: 10),
              Text(
                "New Post",
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          Obx(
            () => TextButton(
              onPressed: () {
                if (controller.content.value.isNotEmpty) {
                  controller
                      .store(Get.find<SupabaseService>().currentUser.value!.id);
                }
              },
              child: controller.loading.value
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator.adaptive(),
                    )
                  : Text(
                      "Post",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: controller.content.value.isNotEmpty
                              ? FontWeight.bold
                              : FontWeight.normal),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
