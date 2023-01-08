import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:piwigo/utils/mutex.dart';
import 'package:rxdart/subjects.dart';
import 'package:video_player/video_player.dart';

class Player {
  final String url;
  final VideoPlayerController controller;
  Player({required this.url})
      : controller = VideoPlayerController.network(url,
            videoPlayerOptions: VideoPlayerOptions(
              mixWithOthers: true,
            ));
  Completer<void>? _completer;
  Future<void> initialize() async {
    if (_completer != null) {
      return _completer!.future;
    }
    _completer = Completer<void>();
    try {
      await controller.initialize();
      _completer!.complete();
    } catch (e) {
      final completer = _completer!;
      _completer = null;
      completer.completeError(e);
      return completer.future;
    }
    return _completer!.future;
  }

  Future<void> _dispose() async {
    await controller.dispose();
  }
}

class PlayerManage {
  static PlayerManage? _instance;
  static PlayerManage get instance => _instance ??= PlayerManage._();
  PlayerManage._();
  Player? _player;
  final _subject = PublishSubject<Player>();
  Stream<Player> get stream => _subject;
  final _mutex = Mutex();
  Player? getInitialized(String url) {
    if (_player?.controller.value.isInitialized ?? false) {
      if (_player!.url == url) {
        return _player!;
      }
    }
    return null;
  }

  Future<Player> get(String url) async {
    await _mutex.lock();
    try {
      return await _get(url);
    } finally {
      _mutex.unlock();
    }
  }

  Future<Player> _get(String url) async {
    // 比對緩存
    final cache = _player;
    if (cache != null) {
      if (cache.url != url || cache.controller.value.hasError) {
        // 緩存錯誤或資源比匹配 釋放資源
        try {
          _subject.add(cache);
          await cache._dispose();
        } catch (e) {
          debugPrint("dispose player error: $e");
        }
      } else {
        // 返回匹配的緩存
        return cache;
      }
    }
    // 創建新資源
    final player = Player(url: url);
    _player = player;
    return player;
  }

  void pause() async {
    final player = _player;
    if (player != null) {
      if (player._completer == null) {
        return;
      }
      await _mutex.lock();
      try {
        if (_player != player) {
          return;
        }
        await player.initialize();
        if (player.controller.value.isPlaying) {
          player.controller.pause();
        }
      } finally {
        _mutex.unlock();
      }
    }
  }
}
