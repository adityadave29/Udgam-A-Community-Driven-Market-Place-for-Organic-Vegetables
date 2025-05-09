import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:udgaam/models/user_model.dart';
import 'package:udgaam/routes/route_names.dart';
import 'package:udgaam/utils/helper.dart';
import 'package:udgaam/utils/styles/button_styles.dart';
import 'package:udgaam/widgets/image_circle.dart';

class UserTile extends StatelessWidget {
  final UserModel user;
  const UserTile({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: CircleImage(url: user.metadata?.image),
      ),
      title: Text(user.metadata!.name!),
      titleAlignment: ListTileTitleAlignment.top,
      trailing: OutlinedButton(
        style: customOutlineStyle(),
        onPressed: () {
          Get.toNamed(Routenames.showUser, arguments: user.id!);
        },
        child: const Text("View profile"),
      ),
      subtitle: Text(formateDateFromNow(user.createdAt!)),
    );
  }
}
