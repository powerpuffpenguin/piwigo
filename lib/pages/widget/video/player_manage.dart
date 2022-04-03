import 'dart:async';

import 'package:flutter/material.dart';
import 'package:piwigo/utils/lru.dart';
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
  Future<Player> get(String url) async {
    // 清理出錯資源
    final list = _lru.toList();
    for (var item in list) {
      final player = item.value;
      final controller = player.controller;
      if (controller.value.hasError) {
        if (_lru.exists(item.key) == player) {
          _lru.delete(item.key);
        }
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
    final list = _lru.toList();
    for (var item in list) {
      if (item.value != player) {
        final controller = item.value.controller;
        if (controller.value.isPlaying && exists(item.value)) {
          try {
            await controller.pause();
          } catch (e) {
            debugPrint('pause error: $e');
          }
        }
      }
    }
    if (exists(player)) {
      await player.controller.play();
    }
  }
}