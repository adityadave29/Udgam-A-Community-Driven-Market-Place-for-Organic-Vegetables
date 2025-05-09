import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:udgaam/controllers/post_controller.dart';
import 'package:udgaam/models/post_model.dart';
import 'package:udgaam/routes/route_names.dart';
import 'package:udgaam/services/supabase_service.dart';

class BottomBarPostCard extends StatefulWidget {
  final PostModel post;
  const BottomBarPostCard({super.key, required this.post});

  @override
  State<BottomBarPostCard> createState() => _BottomBarPostCardState();
}

class _BottomBarPostCardState extends State<BottomBarPostCard> {
  String likeStatus = "";
  final PostController controller = Get.find<PostController>();
  final SupabaseService supabaseService = Get.find<SupabaseService>();

  void likeDislike(String status) async {
    setState(() {
      likeStatus = status;
    });

    if (likeStatus == "0") {
      widget.post.likes = [];
    }

    await controller.likeDislike(status, widget.post.id!, widget.post.userId!,
        supabaseService.currentUser.value!.id);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            likeStatus == "1" || widget.post.likes!.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      likeDislike("0");
                    },
                    icon: Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                  )
                : IconButton(
                    onPressed: () {
                      likeDislike("1");
                    },
                    icon: Icon(Icons.favorite_outline),
                  ),
            IconButton(
              onPressed: () {
                Get.toNamed(Routenames.addReply, arguments: widget.post);
              },
              icon: Icon(Icons.chat_bubble_outline),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.send_outlined),
            ),
          ],
        ),
        Row(
          children: [
            Text("${widget.post.commentCount} replies"),
            const SizedBox(width: 10),
            Text("${widget.post.likeCount} likes"),
          ],
        ),
      ],
    );
  }
}
