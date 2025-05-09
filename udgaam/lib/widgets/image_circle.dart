import 'dart:io';
import 'package:flutter/material.dart';
import 'package:udgaam/utils/helper.dart';

class CircleImage extends StatelessWidget {
  final String? url;
  final File? file;
  final double radius;

  const CircleImage({
    this.url,
    this.file,
    this.radius = 20,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (file != null)
          CircleAvatar(
            backgroundImage: FileImage(file!),
            radius: radius,
          )
        else if (url != null)
          CircleAvatar(
            radius: radius,
            backgroundImage: NetworkImage(
              getS3Url(url!),
            ),
          )
        else
          CircleAvatar(
            radius: radius,
            backgroundImage: const AssetImage("assets/avatar.png"),
          ),
      ],
    );
  }
}
