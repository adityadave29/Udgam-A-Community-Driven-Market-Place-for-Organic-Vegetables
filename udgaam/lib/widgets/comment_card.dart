import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:udgaam/models/reply_model.dart';
import 'package:udgaam/widgets/comment_top_bar.dart';
import 'package:udgaam/widgets/image_circle.dart';

class CommentCard extends StatelessWidget {
  final ReplyModel reply;
  const CommentCard({super.key, required this.reply});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: context.width * 0.12,
              child: CircleImage(url: reply.user?.metadata?.image),
            ),
            const SizedBox(width: 10),
            SizedBox(
                width: context.width * 0.80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommentTopBar(reply: reply),
                    Text(reply.reply!),
                  ],
                ))
          ],
        ),
        Divider(
          color: Color(0xff242424),
        ), // Add a divider line
      ],
    );
  }
}
