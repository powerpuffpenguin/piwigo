import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piwigo/environment.dart';
import 'package:piwigo/pages/widget/listener/keyboard_listener.dart';
import 'package:piwigo/pages/widget/photo_view.dart';
import 'package:piwigo/pages/widget/swiper/swiper.dart';
import 'package:piwigo/pages/widget/video/player_manage.dart';
import 'package:piwigo/rpc/webapi/categories.dart';
import 'package:piwigo/utils/path.dart';
import 'package:rxdart/subjects.dart';

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
  final _focusNode = FocusNode();
  final _subject = PublishSubject<KeyEvent>();
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
    _focusNode.dispose();
    _subject.close();
    PlayerManage.instance.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: MyEnvironment.isProduct
          ? null
          : FloatingActionButton(onPressed: () {
              _subject.add(const MyKeyEvent(
                physicalKey: PhysicalKeyboardKey.abort,
                logicalKey: LogicalKeyboardKey.arrowDown,
                timeStamp: Duration(seconds: 1),
              ));
            }),
      body: MyKeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyTab: (evt) {
          _subject.add(evt);
          if (evt.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (!_showController) {
              final val = widget.controller.value - 1;
              widget.controller.swipeTo(val);
            }
          } else if (evt.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (!_showController) {
              final val = widget.controller.value + 1;
              widget.controller.swipeTo(val);
            }
          }
        },
        builder: (context) => Swiper(
          controller: widget.controller,
          itemCount: widget.source.length,
          itemBuilder: (context, details) {
            final image = widget.source[details.index];
            return MyPhotoView(
              stream: _subject,
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
      ),
    );
  }
}

class MyKeyEvent extends KeyEvent {
  const MyKeyEvent({
    required PhysicalKeyboardKey physicalKey,
    required LogicalKeyboardKey logicalKey,
    required Duration timeStamp,
  }) : super(
            physicalKey: physicalKey,
            logicalKey: logicalKey,
            timeStamp: timeStamp);
}
