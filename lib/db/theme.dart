import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyTheme {
  static const supported = <String>[
    "light",
    "dark",
  ];
  static MyTheme? _instance;
  static MyTheme get instance {
    if (_instance == null) {
      _instance = MyTheme._();
      _instance!._subject.add(null);
      _instance!._system.add(Brightness.light);
    }
    return _instance!;
  }

  MyTheme._();
  factory MyTheme() => instance;

  String? _use;
  final _subject = BehaviorSubject<String?>();
  final _system = BehaviorSubject<Brightness?>();
  close() {
    _subject.close();
    _system.close();
  }

  Stream<String?> get subject => _subject;
  Stream<Brightness?> get system => _system;
  Future<void> addSystem(Brightness data) async {
    if (data != _system.value) {
      debugPrint('set system theme to stream: $data');
      _system.add(data);
    }
    if (data == Brightness.dark) {
      await saveSystem("dark");
    } else if (data == Brightness.light) {
      await saveSystem("light");
    } else {
      debugPrint('unknow system theme $data');
      await saveSystem(null);
    }
  }

  Future<String?> load() {
    return loadSystem().then((_) => loadTheme());
  }

  Future<void> loadSystem() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString("system_theme");
      debugPrint('load system theme: $name');
      if (name == "dark") {
        _system.add(Brightness.dark);
      } else if (name == "light") {
        _system.add(Brightness.light);
      } else {
        _system.add(Brightness.light);
      }
    } catch (e) {
      debugPrint('load system theme error: $e');
    }
  }

  Future<void> saveSystem(String? name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final theme = prefs.getString("system_theme");
      if (theme == name) {
        return;
      }
      if (name == null) {
        await prefs.remove("system_theme");
      } else {
        debugPrint('save system theme: $name');
        await prefs.setString("system_theme", name);
      }
    } catch (e) {
      debugPrint('save system theme error: $e');
    }
  }

  Future<String?> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final theme = prefs.getString("theme");
      if (theme is! String || theme.isEmpty || !supported.contains(theme)) {
        if (_use != null) {
          _use = null;
          _subject.add(null);
        }
        return null;
      }
      if (_use != theme) {
        _use = theme;
        _subject.add(theme);
      }
      return theme;
    } catch (e) {
      rethrow;
    }
  }

  saveTheme(String name) async {
    if (_use == name) {
      return;
    }
    if (!supported.contains(name)) {
      throw Exception("not support theme : $name");
    }
    _use = name;
    _subject.add(name);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("theme", name);
  }

  clear() async {
    if (_use == null) {
      return;
    }
    _use = null;
    _subject.add(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("theme");
  }

  static ThemeData? getTheme(String? name) {
    if (name == null) {
      return null;
    }
    if (name == supported[0]) {
      return ThemeData.light();
    } else if (name == supported[1]) {
      return ThemeData.dark();
    }
    return null;
  }
}
