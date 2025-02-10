import 'package:flutter/material.dart';
import 'package:piwigo/db/settings.dart';

const qualityFast = '0';
const qualityNormal = '1';
const qualityQuality = '2';
const qualityRaw = '3';

const qualityList = [
  qualityFast,
  qualityNormal,
  qualityQuality,
  qualityRaw,
];

class MyQuality {
  static MyQuality? _instance;
  static MyQuality get instance {
    return _instance ??= MyQuality._();
  }

  MyQuality._();

  String _data = qualityQuality;
  Future<void> load() async {
    try {
      final str = await MySettings.instance.getString("settings.quality");
      if (str != '') {
        _data = str;
      }
    } catch (e) {
      debugPrint('load settings.image error: $e');
    }
  }

  String get data => _data;
  Future<void> setData(String v) async {
    if (_data == v) {
      return;
    }
    await MySettings.instance.setString("settings.quality", v);
    _data = v;
  }
}
