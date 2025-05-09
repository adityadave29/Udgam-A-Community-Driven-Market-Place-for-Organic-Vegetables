import 'dart:io';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udgaam/models/post_model.dart';
import 'package:udgaam/models/reply_model.dart';
import 'package:udgaam/models/user_model.dart';
import 'package:udgaam/services/supabase_service.dart';
import 'package:udgaam/utils/env.dart';
import 'package:udgaam/utils/helper.dart';

class ProfileController extends GetxController {
  var loading = false.obs;
  Rx<File?> image = Rx<File?>(null);
  var postLoading = false.obs;
  RxList<PostModel> posts = RxList<PostModel>();
  var replyLoading = false.obs;
  RxList<ReplyModel> replies = RxList<ReplyModel>();

  var userLoading = false.obs;
  Rx<UserModel> user = Rx<UserModel>(UserModel());

  Future<void> updateProfile(String userId, String description) async {
    try {
      loading.value = true;
      var uploadedPath = "";
      if (image.value != null && image.value!.existsSync()) {
        final String dir = "$userId/profile.jpg";
        var path = await SupabaseService.client.storage
            .from(Env.s3Bucket)
            .upload(dir, image.value!,
                fileOptions: const FileOptions(upsert: true));

        uploadedPath = path;
      }

      await SupabaseService.client.auth.updateUser(UserAttributes(data: {
        "description": description,
        "image": uploadedPath.isNotEmpty ? uploadedPath : null
      }));
      loading.value = false;
      Get.back();
      showSnackBar("Success", "Updated!");
    } on StorageException catch (e) {
      loading.value = false;
      showSnackBar("Error", e.message);
    } on AuthException catch (e) {
      loading.value = false;
      showSnackBar("Error", e.message);
    } catch (e) {
      loading.value = false;
      showSnackBar("Error", "");
    }
  }

  void pickImage() async {
    File? file = await pickImageFromGallary();
    if (file != null) {
      image.value = file;
    }
  }

  void fetchUserPosts(String userId) async {
    try {
      postLoading.value = true;
      final List<dynamic> response =
          await SupabaseService.client.from("posts").select('''
    id, content, image, created_at, comment_count, like_count, user_id, 
    user: user_id(email, metadata), likes: likes(user_id,post_id)
''').eq("user_id", userId).order("id", ascending: false);
      postLoading.value = false;

      if (response.isNotEmpty) {
        posts.value = [for (var item in response) PostModel.fromJson(item)];
      }
    } catch (e) {
      postLoading.value = false;
      showSnackBar("Error", "Something went wrong");
    }
  }

  Future<void> getUser(String userId) async {
    userLoading.value = true;
    var data = await SupabaseService.client
        .from("users")
        .select("*")
        .eq("id", userId)
        .single();
    userLoading.value = false;
    user.value = UserModel.fromJson(data);

    // * Fetch posts and comments
    fetchUserPosts(userId);
    fetchComments(userId);
  }

  Future<void> deletePost(int postId) async {
    try {
      print("Attempting to delete post with ID: $postId");

      // Delete related notifications first
      await SupabaseService.client
          .from("notifications")
          .delete()
          .eq("post_id", postId);

      // Now delete the post
      await SupabaseService.client.from("posts").delete().eq("id", postId);

      posts.removeWhere((element) => element.id == postId);
      posts.refresh(); // Ensure UI updates
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      showSnackBar("Success", "Post deleted successfully!");
    } on PostgrestException catch (e) {
      print("PostgrestException: ${e.message}");
      showSnackBar("Error", e.message);
    } catch (e) {
      print("Unexpected error: $e");
      showSnackBar("Error", "Something went wrong. Please try again.");
    }
  }

  Future<void> deleteReply(int replyId) async {
    try {
      await SupabaseService.client.from("comments").delete().eq("id", replyId);

      replies.removeWhere((element) => element.id == replyId);
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      showSnackBar("Success", "Reply deleted successfully!");
    } catch (e) {
      showSnackBar("Error", "Something went wrong.pls try again.");
    }
  }

  void fetchComments(String userId) async {
    try {
      replyLoading.value = true;
      final List<dynamic> response = await SupabaseService.client
          .from("comments")
          .select('''
    id, user_id, post_id, reply, created_at, 
    user: user_id(email, metadata)''')
          .eq("user_id", userId)
          .order("id", ascending: false);
      replyLoading.value = false;

      if (response.isNotEmpty) {
        replies.value = [for (var item in response) ReplyModel.fromJson(item)];
      }
    } catch (e) {
      replyLoading.value = false;
      showSnackBar("Error", "Something went wrong");
    }
  }
}
