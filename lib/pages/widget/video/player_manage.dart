import 'dart:async';

import 'package:flutter/material.dart';
import 'package:piwigo/utils/lru.dart';
import 'package:piwigo/utils/mutex.dart';
import 'package:rxdart/subjects.dart';
import 'package:video_player/video_player.dart';

class Player {
  final String url;
  final VideoPlayerController controller;
  Player({required this.url})
      : controller = VideoPlayerController.network(url)..setLooping(true);
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
  final _lru = Lru<String, Player>(4);
  final _subject = PublishSubject<Player>();
  Stream<Player> get stream => _subject;
  final _mutex = Mutex();
  Future<Player> get(String url) async {
    await _mutex.lock();
    try {
      return await _get(url);
    } finally {
      _mutex.unlock();
    }
  }

  Future<Player> _get(String url) async {
    // 清理出錯資源
    final list = _lru.toList();
    for (var item in list) {
      final player = item.value;
      final controller = player.controller;
      if (controller.value.hasError) {
        _lru.delete(item.key);
        await _remove(player);
      }
    }

    // 查找緩存
    final cache = _lru.get(url);
    if (cache != null) {
      return cache;
    }

    /// 佔用太多資源 等待刪除後才創建新的播放器
    if (_lru.isFull) {
      final pop = _lru.pop();
      if (pop != null) {
        await _remove(pop);
      }
    }

    final player = Player(url: url);
    _lru.put(url, player);
    return player;
  }

  Future<void> _remove(Player player) async {
    _subject.add(player);
    await player._dispose();
  }

  bool exists(Player player) => _lru.exists(player.url) == player;
  Future<void> play(Player player) async {
    await _mutex.lock();
    try {
      await _play(player);
    } finally {
      _mutex.unlock();
    }
  }

  Future<void> _play(Player player) async {
    if (!exists(player)) {
      return;
    }
    final list = _lru.list;
    for (var item in list) {
      if (item.value != player) {
        final controller = item.value.controller;
        if (controller.value.isPlaying) {
          try {
            await controller.pause();
          } catch (e) {
            debugPrint('pause error: $e');
          }
        }
      }
    }
    await player.controller.play();
  }
}
