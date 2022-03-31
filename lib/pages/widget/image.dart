import 'package:flutter/material.dart';
import 'package:piwigo/rpc/webapi/categories.dart';
import 'package:piwigo/utils/wrap.dart';

class MyImage extends StatelessWidget {
  const MyImage({
    Key? key,
    required this.image,
    required this.width,
    required this.height,
  }) : super(key: key);

  final double width;
  final double height;
  final PageImage image;
  @override
  Widget build(BuildContext context) {
    return Image.network(
      image.derivatives.smallXX.url,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }

  /// 傳入佈局寬度，返回組件適合的寬度
  static double calculateWidth(double w) {
    const min = 100.0;
    const max = 115.0;
    late double width;
    if (w <= max) {
      width = w;
    } else if (w < min * 2) {
      width = max;
    } else if (w < max * 2) {
      width = w / 2;
    } else if (w < min * 3) {
      width = max;
    } else if (w < max * 3) {
      width = w / 3;
    } else {
      width = max;
    }
    return width;
  }

  static double calculateHeight(double width) => width * 9 / 16;
  static MyWrap calculateWrap(
    Size size,
    double spacing,
    int count,
  ) {
    final w = size.width - spacing * 2;
    final width = calculateWidth(w);
    final height = calculateHeight(width);
    final cols = w ~/ width;
    final viewWidth = cols * width;
    final fit = cols * size.height ~/ height;
    final rows = (count + cols - 1) ~/ cols;
    return MyWrap(
      spacing: spacing,
      viewWidth: viewWidth,
      width: width,
      height: height,
      cols: cols,
      rows: rows,
      fit: fit,
    );
  }
}
