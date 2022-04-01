import 'package:flutter/material.dart';
import 'package:piwigo/pages/widget/photo_view.dart';
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
    return Scaffold(
      body: Swiper(
        controller: widget.controller,
        itemCount: widget.source.length,
        itemBuilder: (context, details) {
          final image = widget.source[details.index];
          return MyPhotoView(
            image: image,
            controller: widget.controller,
            count: widget.source.length,
            swipe: details.swipe,
          );
        },
      ),
    );
  }
}
