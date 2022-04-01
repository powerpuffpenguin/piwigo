import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:piwigo/pages/widget/swiper/swiper.dart';
import 'package:piwigo/rpc/webapi/categories.dart';

class MyFullscreenPage extends StatefulWidget {
  const MyFullscreenPage({
    Key? key,
    required this.source,
    required this.controller,
  }) : super(key: key);
  final List<PageImage> source;
  final SwiperController controller;
  @override
  _MyFullscreenPageState createState() => _MyFullscreenPageState();
}

class _MyFullscreenPageState extends State<MyFullscreenPage> {
  @override
  Widget build(BuildContext context) {
    return Swiper(
      controller: widget.controller,
      itemCount: widget.source.length,
      itemBuilder: (context, i) {
        final node = widget.source[i];
        return Listener(
          onPointerMove: (v) {
            // debugPrint('onPointerMove $v');
          },
          onPointerSignal: (v) {
            debugPrint('onPointerSignal $v');
          },
          onPointerDown: (v) {
            debugPrint('onPointerDown $v');
          },
          onPointerUp: (v) {
            debugPrint('onPointerUp $v');
          },
          child: Listener(
            onPointerMove: (v) {
              // debugPrint('onPointerMove $v');
            },
            onPointerSignal: (v) {
              debugPrint('onPointerSignal $v');
            },
            onPointerDown: (v) {
              debugPrint('onPointerDown $v');
            },
            onPointerUp: (v) {
              debugPrint('onPointerUp $v');
            },
            child: PhotoView(
              imageProvider: NetworkImage(node.derivatives.smallXX.url),
              initialScale: 1.0,
              disableGestures: true,
            ),
          ),
        );
      },
    );
  }
}
