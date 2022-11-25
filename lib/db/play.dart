import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:piwigo/db/settings.dart';

class Play {
  // 是否啓動 全屏時自動播放
  bool opend;
  // 自動播放時照片等待多久播放下一個
  int seconds;

  Play clone() => Play(
        opend: opend,
        seconds: seconds,
      );
  bool equal(Play o) {
    return opend == o.opend && seconds == o.seconds;
  }

  Play({
    this.opend = false,
    this.seconds = 5,
  });
  Play.fromJson(Map<String, dynamic> json)
      : opend = json["opend"] ?? false,
        seconds = json["seconds"] ?? 5;

  Map<String, dynamic> toJson() => {
        "opend": opend,
        "seconds": seconds,
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
    if (v.equal(_data)) {
      return;
    }
    await MySettings.instance.setString("settings.play", jsonEncode(v));
    _data = v;
  }
}
