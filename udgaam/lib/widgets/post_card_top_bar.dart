import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:udgaam/models/post_model.dart';
import 'package:udgaam/routes/route_names.dart';
import 'package:udgaam/utils/helper.dart';
import 'package:udgaam/utils/type_def.dart';

class TopBarPostCard extends StatelessWidget {
  final PostModel post;
  final bool isAuthCard;
  final DeleteCallback? callback;
  TopBarPostCard({
    super.key,
    required this.post,
    this.isAuthCard = false,
    this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Get.toNamed(Routenames.showUser, arguments: post.userId),
          child: Text(post.user!.metadata!.name!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                // fontSize: 18,
              )),
        ),
        Row(
          children: [
            Text(formateDateFromNow(post.createdAt!)),
            const SizedBox(width: 10),
            isAuthCard
                ? GestureDetector(
                    onTap: () {
                      confirmDialogue(
                          "Are you sure ?", "you won't be able to recover", () {
                        callback!(post.id!);
                      });
                    },
                    child: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  )
                : const Icon(Icons.more_horiz),
          ],
        ),
      ],
    );
  }
}
