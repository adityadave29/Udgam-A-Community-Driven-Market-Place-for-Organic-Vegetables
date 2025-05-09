import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:udgaam/models/post_model.dart';
import 'package:udgaam/routes/route_names.dart';
import 'package:udgaam/utils/type_def.dart';
import 'package:udgaam/widgets/image_circle.dart';
import 'package:udgaam/widgets/post_card_bottom_bar.dart';
import 'package:udgaam/widgets/post_card_image.dart';
import 'package:udgaam/widgets/post_card_top_bar.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final bool isAuthCard;
  final DeleteCallback? callback;
  const PostCard(
      {required this.post, super.key, this.isAuthCard = false, this.callback});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: context.width * 0.12,
                child: CircleImage(
                  url: post.user?.metadata?.image,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: context.width * 0.80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TopBarPostCard(
                      post: post,
                      callback: callback,
                      isAuthCard: isAuthCard,
                    ),
                    GestureDetector(
                        onTap: () => {
                              Get.toNamed(
                                Routenames.showPost,
                                arguments: post.id,
                              ),
                            },
                        child: Text(post.content!)),
                    const SizedBox(height: 10),
                    if (post.image != null)
                      GestureDetector(
                          onTap: () {
                            Get.toNamed(
                              Routenames.showImage,
                              arguments: post.image!,
                            );
                          },
                          child: ImagePostCard(url: post.image!)),
                    BottomBarPostCard(post: post),
                  ],
                ),
              ),
            ],
          ),
          const Divider(
            color: Color(0xff242424),
          ),
        ],
      ),
    );
  }
}
