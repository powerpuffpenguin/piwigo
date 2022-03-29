import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Language {
  final Locale locale;
  late String name;
  final String description;

  Language({
    required this.locale,
    required this.description,
  }) {
    name = locale.toString();
  }
}

final defaultLanguage = Language(
  locale: const Locale('en', 'US'),
  description: "English US",
);

/// 定義支持的語言
final supportedLanguage = <Language>[
  Language(
    locale: const Locale('zh', 'TW'),
    description: "正體中文",
  ),
  Language(
    locale: const Locale('zh', 'CN'),
    description: "简体中文",
  ),
  defaultLanguage,
];

Map<String, Language>? _supported;
Map<String, Language> getSupported() {
  if (_supported == null) {
    _supported = <String, Language>{};
    for (var item in supportedLanguage) {
      debugPrint('support language ${item.name} ${item.locale}');
      _supported![item.name] = item;
    }
  }
  return _supported!;
}

bool isSupported(Locale locale) {
  return locale.languageCode.startsWith('zh') ||
      locale.languageCode.startsWith('en');
}

class MyLanguage {
  static String? _languageUse;
  static MyLanguage? _instance;
  static MyLanguage get instance {
    if (_instance == null) {
      _instance = MyLanguage._();
      _instance!._subject.add(null);
    }
    return _instance!;
  }

  static Locale? myLocaleResolutionCallback(
    Locale? locale,
    Iterable<Locale> supportedLocales,
  ) {
    final supported = getSupported();
    if (_languageUse != null) {
      final find = supported[_languageUse];
      if (find != null) {
        return find.locale;
      }
    }

    String name = locale.toString().toLowerCase();
    final find = supported[name];
    if (find != null) {
      return find.locale;
    } else if (name.startsWith('zh_cn') || name.startsWith('zh_hans')) {
      return supported['zh_CN']!.locale;
    } else if (name.startsWith('zh')) {
      return supported['zh_TW']!.locale;
    }
    return defaultLanguage.locale;
  }

  MyLanguage._();
  factory MyLanguage() => instance;

  final _subject = BehaviorSubject<String?>();
  close() => _subject.close();
  Stream<String?> get subject => _subject;

  Future<String?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final language = prefs.getString("language");
      if (language is! String || language.isEmpty) {
        if (_languageUse != null) {
          _languageUse = null;
          _subject.add(null);
        }
        return null;
      }
      final supported = getSupported();
      final find = supported[language];
      if (find == null) {
        if (_languageUse != null) {
          _languageUse = null;
          _subject.add(null);
        }
      } else {
        if (_languageUse != language) {
          _languageUse = language;
          _subject.add(language);
        }
      }
      return language;
    } catch (e) {
      rethrow;
    }
  }

  save(String name) async {
    if (_languageUse == name) {
      return;
    }
    final supported = getSupported();
    final find = supported[name];
    if (find == null) {
      throw Exception("not support language : $name");
    }

    _languageUse = name;
    _subject.add(name);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("language", name);
  }

  clear() async {
    if (_languageUse == null) {
      return;
    }
    _languageUse = null;
    _subject.add(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("language");
  }

  static Locale? get locale {
    final supported = getSupported();
    return supported[_languageUse]?.locale;
  }
}
