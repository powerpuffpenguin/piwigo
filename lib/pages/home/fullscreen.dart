import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piwigo/pages/widget/photo_view.dart';
import 'package:piwigo/pages/widget/swiper/swiper.dart';
import 'package:piwigo/rpc/webapi/categories.dart';
import 'package:piwigo/utils/path.dart';

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
  bool _showController = false;
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Swiper(
        controller: widget.controller,
        itemCount: widget.source.length,
        itemBuilder: (context, details) {
          final image = widget.source[details.index];
          return MyPhotoView(
            isVideo: isVideoFile(image.file),
            image: image,
            controller: widget.controller,
            count: widget.source.length,
            swipe: details.swipe,
            initShowController: _showController,
            onShowController: (v) {
              _showController = v;
            },
          );
        },
      ),
    );
  }
}
