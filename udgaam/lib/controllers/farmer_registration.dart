import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udgaam/routes/route_names.dart';
import 'package:udgaam/services/storage_service.dart';
import 'package:udgaam/services/supabase_service.dart';
import 'package:udgaam/utils/helper.dart';
import 'package:udgaam/utils/storage_keys.dart';

class FarmerRegiatrationController extends GetxController {
  Rx<File?> farmImage = Rx<File?>(null);
  Rx<File?> certificate = Rx<File?>(null);
  final ImagePicker picker = ImagePicker();
  final ImagePicker picker2 = ImagePicker();
  final registerLoading = false.obs;

  void pickFarmImage() async {
    XFile? file = await picker.pickMedia();

    if (file != null) {
      File selectedFile = File(file.path);
      farmImage.value = selectedFile;
    }
  }

  void certificateImage() async {
    XFile? file2 = await picker2.pickMedia();

    if (file2 != null) {
      File selectedFile = File(file2.path);
      certificate.value = selectedFile;
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      registerLoading.value = true;
      final AuthResponse data = await SupabaseService.client.auth
          .signUp(email: email, password: password, data: {
        "name": name,
        "role": "Farmer",
      });

      registerLoading.value = false;
      if (data.user != null) {
        StorageService.session
            .write(StorageKeys.userSession, data.session!.toJson());

        Get.offAllNamed(Routenames.farmerreghome);
      }
    } on AuthException catch (error) {
      registerLoading.value = false;
      showSnackBar("Error", error.message);
    }
  }
}
