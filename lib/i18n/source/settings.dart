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
  String get random => Intl.message(
        'SettingsPlay.random',
        desc: '隨機播放相冊',
      );
  String get loop => Intl.message(
        'SettingsPlay.loop',
        desc: '循環播放相冊',
      );
  String get waitSeconds => Intl.message(
        'SettingsPlay.waitSeconds',
        desc: '等待秒數',
      );
}

class SettingsQuality {
  const SettingsQuality();

  String get title => Intl.message(
        'SettingsQuality.title',
        desc: '頁面標題 : 照片質量',
      );

  String get fast => Intl.message(
        'SettingsQuality.fast',
        desc: '優化速度',
      );
  String get normal => Intl.message(
        'SettingsQuality.normal',
        desc: '普通 (建議手機)',
      );
  String get quality => Intl.message(
        'SettingsQuality.quality',
        desc: '優化品質 (默認)',
      );
  String get raw => Intl.message(
        'SettingsQuality.raw',
        desc: '原始圖片(建議 TV)',
      );
}
