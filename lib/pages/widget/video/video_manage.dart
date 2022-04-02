import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:piwigo/utils/lru.dart';
import 'package:video_player/video_player.dart';

class MyPlayerController {
  final String url;

  /// 引用計數
  int _count = 1;
  MyPlayerController({
    required this.url,
  });
  Completer<VideoPlayerController>? _completer;
  VideoPlayerController? _controller;
  VideoPlayerController? get controller => _controller;

  Future<VideoPlayerController> initialize() async {
    if (_completer != null) {
      return _completer!.future;
    }
    var completer = Completer<VideoPlayerController>();
    _completer = completer;
    try {
      final controller = VideoPlayerController.network(url)..setLooping(true);
      await controller.initialize();
      _controller = controller;
      completer.complete(controller);
    } catch (e) {
      debugPrint('initialize video error: $e');
      _completer = null;
      completer.completeError(e);
      return completer.future;
    }
    return _completer!.future;
  }

  FutureOr<void> _dispose() async {
    if (_completer == null) {
      return;
    }
    try {
      final controller = await _completer!.future;
      controller.dispose();
    } catch (_) {}
  }
}

class MyVideoPlayerManage {
  static final _lru = Lru<String, MyPlayerController>(5);
  static final _keys = <String, MyPlayerController>{};
  static MyPlayerController get(String url) {
    final val = _keys[url];
    if (val != null) {
      val._count++;
      return val;
    }
    final controller = MyPlayerController(url: url);
    _keys[url] = controller;
    return controller;
  }

  static void put(MyPlayerController val) {
    val._count--;
    if (val._count != 0) {
      return;
    }
    try {
      val.controller?.pause();
    } catch (_) {}

    final player = _lru.put(val.url, val);
    if (player != null) {
      player._dispose();
    }
  }
}
