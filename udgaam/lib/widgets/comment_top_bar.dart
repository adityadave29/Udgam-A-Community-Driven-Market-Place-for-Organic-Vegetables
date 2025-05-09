import 'package:flutter/material.dart';
import 'package:udgaam/models/reply_model.dart';
import 'package:udgaam/utils/helper.dart';

class CommentTopBar extends StatelessWidget {
  final ReplyModel reply;
  const CommentTopBar({super.key, required this.reply});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(reply.user!.metadata!.name!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              // fontSize: 18,
            )),
        Row(
          children: [
            Text(formateDateFromNow(reply.createdAt!)),
            const SizedBox(width: 10),
            const Icon(Icons.more_horiz),
          ],
        ),
      ],
    );
  }
}
