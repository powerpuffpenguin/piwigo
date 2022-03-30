import 'package:flutter/material.dart';
import 'package:piwigo/rpc/webapi/categories.dart';

class MyImage extends StatelessWidget {
  const MyImage({
    Key? key,
    required this.src,
    required this.image,
    required this.width,
    required this.height,
  }) : super(key: key);

  final double width;
  final double height;
  final PageImage image;
  final String src;
  @override
  Widget build(BuildContext context) {
    return Image.network(
      src,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }
}
