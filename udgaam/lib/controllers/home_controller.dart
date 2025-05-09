import 'package:get/get.dart';
import 'package:udgaam/models/post_model.dart';
import 'package:udgaam/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udgaam/models/user_model.dart';

class HomeController extends GetxController {
  var loading = false.obs;
  RxList<PostModel> posts = RxList<PostModel>();
  RxList<PostModel> filteredPosts = RxList<PostModel>();
  var selectedCategory = 'General'.obs;

  final Map<String, String> categories = {
    'सभी': 'General', // To show all posts
    'फसल प्रबंधन': 'Crop Management',
    'मौसम और जलवायु': 'Weather & Climate',
    'कृषि उपकरण और तकनीक': 'Farming Equipment & Technology',
    'बाजार और मूल्य': 'Market & Pricing',
    'पशुपालन': 'Animal Husbandry',
    'अन्य': 'Other'
  };

  @override
  void onInit() async {
    await fetchPosts();
    listenPostChange();
    super.onInit();
  }

  Future<void> fetchPosts() async {
    loading.value = true;
    final List<dynamic> response =
        await SupabaseService.client.from("posts").select('''
    id, content, image, created_at, comment_count, like_count, user_id, category,
    user: user_id(email, metadata), likes: likes(user_id,post_id)
''').order("id", ascending: false);

    loading.value = false;

    if (response.isNotEmpty) {
      posts.value = [for (var item in response) PostModel.fromJson(item)];
      filterPosts();
    }
  }

  void listenPostChange() {
    SupabaseService.client
        .channel('public:posts')
        .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'posts',
            callback: (payload) {
              print('Change received: ${payload.toString()}');
              final PostModel post = PostModel.fromJson(payload.newRecord);
              updateFeed(post);
            })
        .onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'posts',
            callback: (payload) {
              print('Delete event received: ${payload.toString()}');
              posts.removeWhere((element) => element.id == payload.oldRecord);
            })
        .subscribe();
  }

  void updateFeed(PostModel post) async {
    var user = await SupabaseService.client
        .from("users")
        .select("*")
        .eq("id", post.userId!)
        .single();

    post.likes = [];
    post.user = UserModel.fromJson(user);
    posts.insert(0, post);
    filterPosts();
  }

  void selectCategory(String hindiCategory) {
    selectedCategory.value = categories[hindiCategory] ?? 'General';
    filterPosts();
  }

  void filterPosts() {
    if (selectedCategory.value == 'General') {
      filteredPosts.assignAll(posts);
    } else {
      filteredPosts.assignAll(posts
          .where((post) => post.category == selectedCategory.value)
          .toList());
    }
  }
}
