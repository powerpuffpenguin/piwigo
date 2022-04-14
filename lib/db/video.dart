import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:piwigo/db/settings.dart';

/// 視頻配置，某些 android tv 視頻會翻轉，配置此處可以用於修正問題
class Video {
  // [0,3] 視頻旋轉 rotate * pi /2
  int rotate;
  // [-50,50] 縮放視頻 (100+scale)/100
  int scale;
  // 如果爲 true 反轉寬高比
  bool reverse;

  // [0,3] 視頻旋轉 rotate * pi /2
  int rotate1;
  // [-50,50] 縮放視頻 (100+scale)/100
  int scale1;
  // 如果爲 true 反轉寬高比
  bool reverse1;
  Video clone() => Video(
        rotate: rotate,
        scale: scale,
        reverse: reverse,
        rotate1: rotate1,
        scale1: scale1,
        reverse1: reverse1,
      );
  bool equal(Video o) {
    return rotate == o.rotate &&
        scale == o.scale &&
        reverse == o.reverse &&
        rotate1 == o.rotate1 &&
        scale1 == o.scale1 &&
        reverse1 == o.reverse1;
  }

  Video({
    required this.rotate,
    required this.scale,
    required this.reverse,
    required this.rotate1,
    required this.scale1,
    required this.reverse1,
  });
  Video.fromJson(Map<String, dynamic> json)
      : rotate = json["rotate"] ?? 0,
        scale = json["scale"] ?? 0,
        reverse = json["reverse"] ?? false,
        rotate1 = json["rotate1"] ?? 0,
        scale1 = json["scale1"] ?? 0,
        reverse1 = json["reverse1"] ?? false {
    if (rotate < 0) {
      rotate = 0;
    } else if (rotate > 3) {
      rotate = 3;
    }
    if (scale < -50) {
      scale = -50;
    } else if (scale > 50) {
      scale = 50;
    }

    if (rotate1 < 0) {
      rotate1 = 0;
    } else if (rotate1 > 3) {
      rotate1 = 3;
    }
    if (scale1 < -50) {
      scale1 = -50;
    } else if (scale1 > 50) {
      scale1 = 50;
    }
  }
  Map<String, dynamic> toJson() => {
        "rotate": rotate,
        "scale": scale,
        "reverse": reverse,
        "rotate1": rotate1,
        "scale1": scale1,
        "reverse1": reverse1,
      };
}

class MyVideo {
  static MyVideo? _instance;
  static MyVideo get instance {
    return _instance ??= MyVideo._();
  }

  MyVideo._();

  Video _data = Video(
    rotate: 0,
    scale: 0,
    reverse: false,
    rotate1: 0,
    scale1: 0,
    reverse1: false,
  );
  Future<void> load() async {
    try {
      final str = await MySettings.instance.getString("settings.video");
      if (str.isNotEmpty) {
        final video = Video.fromJson(jsonDecode(str));
        _data = video;
      }
    } catch (e) {
      debugPrint('load settings.video error: $e');
    }
  }

  Video get data => _data.clone();
  Future<void> setData(Video v) async {
    if (v.equal(_data)) {
      return;
    }
    await MySettings.instance.setString("settings.video", jsonEncode(v));
    _data = v;
  }
}
