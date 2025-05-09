import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udgaam/models/post_model.dart';
import 'package:udgaam/models/reply_model.dart';
import 'package:udgaam/services/navigation_service.dart';
import 'package:udgaam/services/supabase_service.dart';
import 'package:udgaam/utils/env.dart';
import 'package:udgaam/utils/helper.dart';
import 'package:uuid/uuid.dart';

class PostController extends GetxController {
  final TextEditingController textEditingController =
      TextEditingController(text: "");

  var content = "".obs;
  var loading = false.obs;
  Rx<File?> image = Rx<File?>(null);
  var selectedCategory = "सामान्य".obs;

  var showPostLoading = false.obs;
  Rx<PostModel> post = Rx<PostModel>(PostModel());

  var commentLoading = false.obs;
  RxList<ReplyModel?> replies = RxList<ReplyModel?>();

  final ImagePicker picker = ImagePicker();

  // Category Map: Hindi Display -> English Storage
  final Map<String, String> categories = {
    'सभी': 'General',
    'फसल प्रबंधन': 'Crop Management',
    'मौसम और जलवायु': 'Weather & Climate',
    'कृषि उपकरण और तकनीक': 'Farming Equipment & Technology',
    'बाजार और मूल्य': 'Market & Pricing',
    'पशुपालन': 'Animal Husbandry',
    'अन्य': 'Other'
  };

  void pickImage() async {
    XFile? file = await picker.pickMedia();

    if (file != null) {
      File selectedFile = File(file.path);
      image.value = selectedFile;
    }
  }

  void store(String userId) async {
    try {
      loading.value = true;
      const uuid = Uuid();
      final dir = "$userId/${uuid.v6()}";
      var imgPath = "";

      if (image.value != null && image.value!.existsSync()) {
        imgPath = await SupabaseService.client.storage
            .from(Env.s3Bucket)
            .upload(dir, image.value!);
      }

      // Convert Hindi category to English before storing
      String categoryInEnglish =
          categories[selectedCategory.value] ?? 'General';

      await SupabaseService.client.from("posts").insert({
        "user_id": userId,
        "content": content.value,
        "category": categoryInEnglish, // Store in English
        "image": imgPath.isNotEmpty ? imgPath : null,
      });

      loading.value = false;
      resetState();
      Get.find<NavigationService>().currentIndex.value = 0;
      showSnackBar("Success", "Post created successfully");
    } on StorageException catch (e) {
      loading.value = false;
      showSnackBar("Error", e.message);
    } catch (e) {
      loading.value = false;
      showSnackBar("Error", "Something went wrong.");
    }
  }

  void show(int postId) async {
    try {
      post.value = PostModel();
      replies.value = [];
      showPostLoading.value = true;
      final response = await SupabaseService.client.from("posts").select('''
    id, content, image, category, created_at, comment_count, like_count, user_id, 
    user: user_id(email, metadata), likes: likes(user_id,post_id)
''').eq("id", postId).single();

      showPostLoading.value = false;
      post.value = PostModel.fromJson(response);

      postComments(postId);
    } catch (e) {
      showPostLoading.value = false;
      showSnackBar("Error", "Something went wrong.");
    }
  }

  void postComments(int postId) async {
    try {
      commentLoading.value = true;
      final List<dynamic> response =
          await SupabaseService.client.from("comments").select('''
    id ,reply ,created_at ,user_id, post_id,
    user:user_id (email , metadata)
''').eq("post_id", postId);
      commentLoading.value = false;
      if (response.isNotEmpty) {
        replies.value = [for (var item in response) ReplyModel.fromJson(item)];
      }
    } catch (e) {
      commentLoading.value = false;
      showSnackBar("Error", "Something went wrong!");
    }
  }

  Future<void> likeDislike(
      String status, int postId, String postUserId, String userId) async {
    if (status == "1") {
      await SupabaseService.client
          .from("likes")
          .insert({"user_id": userId, "post_id": postId});

      await SupabaseService.client.from("notifications").insert({
        "user_id": userId,
        "notification": "liked on your post.",
        "to_user_id": postUserId,
        "post_id": postId,
      });

      await SupabaseService.client
          .rpc("like_increment", params: {"count": 1, "row_id": postId});
    } else if (status == "0") {
      await SupabaseService.client
          .from("likes")
          .delete()
          .match({"user_id": userId, "post_id": postId});

      await SupabaseService.client
          .rpc("like_decrement", params: {"count": 1, "row_id": postId});
    }
  }

  void resetState() {
    content.value = "";
    image.value = null;
    selectedCategory.value = "सामान्य"; // Reset category to default
    textEditingController.text = "";
  }

  @override
  void onClose() {
    textEditingController.dispose();
    super.onClose();
  }
}
