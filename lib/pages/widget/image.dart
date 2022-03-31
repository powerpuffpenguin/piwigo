import 'package:flutter/material.dart';
import 'package:piwigo/pages/widget/fullscreen/fullscreen.dart';
import 'package:piwigo/pages/widget/image_full.dart';
import 'package:piwigo/pages/widget/video.dart';
import 'package:piwigo/rpc/webapi/categories.dart';
import 'package:piwigo/utils/wrap.dart';
import 'package:path/path.dart' as path;

class MyImage extends StatelessWidget {
  const MyImage({
    Key? key,
    required this.image,
    required this.width,
    required this.height,
    required this.fullscreenState,
    required this.offset,
  }) : super(key: key);
  final FullscreenState<PageImage> fullscreenState;
  final double width;
  final double height;
  final PageImage image;
  final int offset;
  @override
  Widget build(BuildContext context) {
    final ext = path.extension(image.file).toLowerCase();
    if (ext == '.ogg' ||
        ext == '.ogv' ||
        ext == '.mp4' ||
        ext == '.m4v' ||
        ext == '.webm' ||
        ext == '.webmv' ||
        ext == '.strm') {
      return MyVideo(
        fullscreenState: fullscreenState,
        width: width,
        height: height,
        image: image,
        offset: offset,
      );
    }
    return GestureDetector(
      onDoubleTap: () {
        fullscreenState.offset = offset;
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return MyImageFull(
            fullscreenState: fullscreenState,
            image: image,
          );
        }));
      },
      child: Image.network(
        image.derivatives.smallXX.url,
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
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
    if (count == 0) {
      return const MyWrap(
          spacing: 0,
          viewWidth: 0,
          width: 0,
          height: 0,
          cols: 0,
          rows: 0,
          fit: 0);
    }
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
