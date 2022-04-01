import 'package:flutter/material.dart';
import 'package:piwigo/pages/widget/fullscreen/fullscreen.dart';
import 'package:piwigo/pages/widget/fullscreen/view_controller.dart';
import 'package:piwigo/rpc/webapi/categories.dart';
import 'package:photo_view/photo_view.dart';

class MyImageFull extends StatefulWidget {
  const MyImageFull({
    Key? key,
    required this.fullscreenState,
    required this.image,
  }) : super(key: key);
  final FullscreenState<PageImage> fullscreenState;
  final PageImage image;
  @override
  _MyImageFullState createState() => _MyImageFullState();
}

class _MyImageFullState extends State<MyImageFull> {
  FullscreenState<PageImage> get fullscreenState => widget.fullscreenState;
  PageImage get image => widget.image;
  bool _showController = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: GestureDetector(
          onTap: () {
            debugPrint('${Navigator.of(context)}');
            setState(() {
              _showController = !_showController;
            });
          },
          child: Stack(
            children: <Widget>[
              _buildPhotoView(context),
              _buildFullscreenController(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoView(BuildContext context) {
    return PhotoView(
      imageProvider: NetworkImage(image.derivatives.smallXX.url),
      initialScale: 1.0,
    );
  }

  Widget _buildFullscreenController(BuildContext context) {
    if (_showController) {
      return Container();
    }
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: MyViewController(
        fullscreenState: widget.fullscreenState,
      ),
    );
  }
}
