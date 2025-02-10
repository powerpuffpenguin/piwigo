import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:piwigo/db/settings.dart';

class Play {
  // 是否啓動 全屏時自動播放
  bool opend;
  // 自動播放時照片等待多久播放下一個
  int seconds;
  // 是否隨機播放相冊
  bool random;
  // 是否循環播放相冊
  bool loop;

  Play clone() => Play(
        opend: opend,
        seconds: seconds,
        random: random,
        loop: loop,
      );
  bool equal(Play o) {
    return opend == o.opend &&
        seconds == o.seconds &&
        random == o.random &&
        loop == o.loop;
  }

  Play({
    this.opend = false,
    this.seconds = 5,
    this.random = false,
    this.loop = false,
  });
  Play.fromJson(Map<String, dynamic> json)
      : opend = json["opend"] ?? false,
        seconds = json["seconds"] ?? 5,
        random = json["random"] ?? false,
        loop = json["loop"] ?? false;

  Map<String, dynamic> toJson() => {
        "opend": opend,
        "seconds": seconds,
        "random": random,
        "loop": loop,
      };
}

class MyPlay {
  static MyPlay? _instance;
  static MyPlay get instance {
    return _instance ??= MyPlay._();
  }

  MyPlay._();

  Play _data = Play();
  Future<void> load() async {
    try {
      final str = await MySettings.instance.getString("settings.play");
      if (str.isNotEmpty) {
        final video = Play.fromJson(jsonDecode(str));
        _data = video;
      }
    } catch (e) {
      debugPrint('load settings.play error: $e');
    }
  }

  Play get data => _data.clone();
  Future<void> setData(Play v) async {
    debugPrint("${v.random} ${_data.random}");
    if (v.equal(_data)) {
      return;
    }
    await MySettings.instance.setString("settings.play", jsonEncode(v));
    _data = v;
  }
}
