import 'package:intl/intl.dart';

class Settings {
  const Settings();

  String get title => Intl.message(
        'Settings.title',
        desc: '頁面標題 : 系統設定',
      );
  String get language => Intl.message(
        'Settings.language',
        desc: '語言設定',
      );
  String get theme => Intl.message(
        'Settings.theme',
        desc: '主題設定',
      );
  String get systemDefault => Intl.message(
        'Settings.systemDefault',
        desc: '系統默認',
      );
}

class SettingsLanguage {
  const SettingsLanguage();

  String get title => Intl.message(
        'SettingsLanguage.title',
        desc: '頁面標題 : 語言設定',
      );
}
