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

class SettingsVideo {
  const SettingsVideo();

  String get title => Intl.message(
        'SettingsVideo.title',
        desc: '頁面標題 : 視頻設定',
      );
  String get reverse => Intl.message(
        'SettingsVideo.reverse',
        desc: '反轉寬高比',
      );
  String get scale => Intl.message(
        'SettingsVideo.scale',
        desc: '縮放',
      );
  String get rotate => Intl.message(
        'SettingsVideo.rotate',
        desc: '旋轉',
      );
}

class SettingsPlay {
  const SettingsPlay();

  String get title => Intl.message(
        'SettingsPlay.title',
        desc: '頁面標題 : 播放設定',
      );
  String get autoplay => Intl.message(
        'SettingsPlay.autoplay',
        desc: '自動播放',
      );
  String get waitSeconds => Intl.message(
        'SettingsPlay.waitSeconds',
        desc: '等待秒數',
      );
}
