import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:udgaam/controllers/profile_controller.dart';
import 'package:udgaam/services/supabase_service.dart';
import 'package:udgaam/widgets/image_circle.dart';

class EditProile extends StatefulWidget {
  const EditProile({super.key});

  @override
  State<EditProile> createState() => _EditProileState();
}

class _EditProileState extends State<EditProile> {
  final TextEditingController textEditingController =
      TextEditingController(text: "");
  final ProfileController controller = Get.find<ProfileController>();
  final SupabaseService supabaseService = Get.find<SupabaseService>();

  @override
  void initState() {
    if (supabaseService.currentUser.value?.userMetadata?["description"] !=
        null) {
      textEditingController.text =
          supabaseService.currentUser.value?.userMetadata?["description"];
    }
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
        actions: [
          Obx(
            () => TextButton(
              onPressed: () {
                controller.updateProfile(supabaseService.currentUser.value!.id,
                    textEditingController.text);
              },
              child: controller.loading.value
                  ? const SizedBox(
                      height: 14,
                      width: 14,
                      child: CircularProgressIndicator(),
                    )
                  : Text("Done"),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            SizedBox(height: 20),
            Obx(
              () => Stack(
                alignment: Alignment.topRight,
                children: [
                  CircleImage(
                    radius: 80,
                    file: controller.image.value,
                    url: supabaseService
                        .currentUser.value?.userMetadata?["image"],
                  ),
                  IconButton(
                    onPressed: () {
                      controller.pickImage();
                    },
                    icon: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.edit),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: textEditingController,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                hintText: "Your Descritption",
                label: Text("Description"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
