import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piwigo/db/play.dart';
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
  final _focusNode = FocusNode();
  final _subject = PublishSubject<KeyEvent>();
  final _showController = ValueNotifier<bool>(false);
  final _autoplayController = ValueNotifier<bool>(MyPlay.instance.data.opend);
  final _finish = StreamController<int>();
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);

    _autoplayController.addListener(_autoplayControllerListener);

    _init();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
    _autoplayController.removeListener(_autoplayControllerListener);
    _focusNode.dispose();
    _subject.close();
    _finish.close();
    PlayerManage.instance.pause();
    super.dispose();
  }

  _init() async {
    await for (var i in _finish.stream) {
      if (i != widget.controller.value || !_autoplayController.value) {
        continue;
      }
      final val = i + 1;
      if (val < widget.source.length) {
        widget.controller.swipeTo(val);
      }
    }
  }

  _autoplayControllerListener() {
    BotToast.showText(text: 'autoplay: ${_autoplayController.value}');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: _build(context),
        onWillPop: () {
          if (_showController.value) {
            _showController.value = false;
            return Future.value(false);
          }
          return Future.value(true);
        });
  }

  Widget _build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: MyEnvironment.isProduct
      //     ? null
      //     : FloatingActionButton(onPressed: () {
      //         _subject.add(const MyKeyEvent(
      //           physicalKey: PhysicalKeyboardKey.abort,
      //           logicalKey: LogicalKeyboardKey.arrowDown,
      //           timeStamp: Duration(seconds: 1),
      //         ));
      //       }),
      body: MyKeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyTab: (evt) {
          if (_showController.value) {
            if (evt.logicalKey == LogicalKeyboardKey.escape) {
              _showController.value = false;
            } else {
              _subject.add(evt);
            }
            return;
          }
          if (evt.logicalKey == LogicalKeyboardKey.arrowLeft) {
            final val = widget.controller.value - 1;
            if (val > -1) {
              widget.controller.swipeTo(val);
            }
          } else if (evt.logicalKey == LogicalKeyboardKey.arrowRight) {
            final val = widget.controller.value + 1;
            if (val < widget.source.length) {
              widget.controller.swipeTo(val);
            }
          } else if (evt.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
          } else if (evt.logicalKey == LogicalKeyboardKey.arrowUp) {
            final ok = !_autoplayController.value;
            _autoplayController.value = ok;
          } else if (evt.logicalKey == LogicalKeyboardKey.select ||
              evt.logicalKey == LogicalKeyboardKey.enter) {
            _showController.value = true;
          } else {
            _subject.add(evt);
          }
        },
        child: Swiper(
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
              showController: _showController,
              autoplayController: _autoplayController,
              sink: _finish.sink,
              index: details.index,
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
