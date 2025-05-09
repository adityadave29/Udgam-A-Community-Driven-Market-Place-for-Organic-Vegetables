import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:udgaam/controllers/post_controller.dart';
import 'package:udgaam/widgets/comment_card.dart';
import 'package:udgaam/widgets/loading.dart';
import 'package:udgaam/widgets/post_card.dart';

class ShowPost extends StatefulWidget {
  const ShowPost({super.key});

  @override
  State<ShowPost> createState() => _ShowPostState();
}

class _ShowPostState extends State<ShowPost> {
  final int postId = Get.arguments;
  final PostController controller = Get.put(PostController());

  @override
  void initState() {
    controller.show(postId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Show Post"),
      ),
      body: Obx(
        () => controller.showPostLoading.value
            ? const Loading()
            : SingleChildScrollView(
                padding: EdgeInsets.all(5),
                child: Column(
                  children: [
                    PostCard(post: controller.post.value),
                    const SizedBox(height: 20),
                    if (controller.commentLoading.value)
                      const Loading()
                    else if (controller.replies.isNotEmpty)
                      ListView.builder(
                        itemCount: controller.replies.length,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) =>
                            CommentCard(reply: controller.replies[index]!),
                      )
                    else
                      Center(
                        child: Text("No replies"),
                      )
                  ],
                ),
              ),
      ),
    );
  }
}
