import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

class MyTheme {
  static const supported = <Tuple2<String, ThemeMode>>[
    Tuple2("light", ThemeMode.light),
    Tuple2("dark", ThemeMode.dark),
  ];
  static bool isSupported(String name) {
    for (var item in supported) {
      if (item.item1 == name) {
        return true;
      }
    }
    return false;
  }

  static MyTheme? _instance;
  static MyTheme get instance {
    return _instance ??= MyTheme._();
  }

  MyTheme._();
  factory MyTheme() => instance;

  final _subject = BehaviorSubject<String>()..add('');
  close() {
    _subject.close();
  }

  Stream<String> get subject => _subject;

  Future<String> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var theme = prefs.getString("theme") ?? '';
      if (theme.isNotEmpty && !isSupported(theme)) {
        theme = '';
      }
      if (_subject.value != theme) {
        _subject.add(theme);
      }
      return theme;
    } catch (e) {
      debugPrint('load theme error: $e');
      return '';
    }
  }

  String get value => _subject.value;
  Future<bool> save(String name) async {
    if (_subject.value == name) {
      return true;
    }
    if (name.isNotEmpty && !isSupported(name)) {
      throw Exception("not support theme : $name");
    }
    _subject.add(name);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("theme", name);
    return true;
  }

  static ThemeMode mode(String name) {
    for (var item in supported) {
      if (item.item1 == name) {
        return item.item2;
      }
    }
    return ThemeMode.system;
  }
}
