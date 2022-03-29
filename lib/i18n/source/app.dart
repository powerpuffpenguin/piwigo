import 'package:intl/intl.dart';

class App {
  const App();
  String get home => Intl.message(
        'App.home',
        desc: '首頁 按鈕/提示文本',
      );
  String get reivew => Intl.message(
        'App.reivew',
        desc: '提供意見 按鈕/提示文本',
      );
  String get settings => Intl.message(
        'App.settings',
        desc: '設定 按鈕/提示文本',
      );
  String get refresh => Intl.message(
        "App.refresh",
        desc: '刷新 按鈕/提示文本',
      );

  String get sucess => Intl.message(
        'App.sucess',
        desc: '成功 標題/提示文本',
      );
  String get save => Intl.message(
        'App.save',
        desc: '保存 按鈕/提示文本',
      );
  String get saveSucess => Intl.message(
        'App.saveSucess',
        desc: '提示信息 : 數據已保存',
      );
  String get issuesHelp => Intl.message(
        'App.issuesHelp',
        desc: '尋求幫助 按鈕/提示文本',
      );
  String get loading => Intl.message(
        'App.loading',
        desc: '正在加載中... 提示文本',
      );
  String get help => Intl.message(
        'App.help',
        desc: '幫助 按鈕/提示文本',
      );

  String get submit => Intl.message(
        'App.submit',
        desc: '提交 按鈕/提示文本',
      );
}

class Error {
  const Error();

  String get title => Intl.message(
        'Error.title',
        desc: '頁面標題 錯誤信息顯示',
      );
  String get noChanged => Intl.message(
        'Error.noChanged',
        desc: '錯誤信息 : 沒有數據改變',
      );
}

class Home {
  const Home();
  String get exitTitle => Intl.message(
        "Home.exitTitle",
        desc: '導航按鈕 : 關閉系統',
      );
  String get exitContext => Intl.message(
        "Home.exitContext",
        desc: '確定要關閉系統嗎？',
      );
  String get search => Intl.message(
        "Home.search",
        desc: '搜索',
      );
  String get name => Intl.message(
        "Home.name",
        desc: '搜索名称',
      );
  String get nameNotSupportEmpty => Intl.message(
        "Home.nameNotSupportEmpty",
        desc: '搜索名称不能为空',
      );
  String get pluginNotSupportEmpty => Intl.message(
        "Home.pluginNotSupportEmpty",
        desc: '請選擇使用的插件',
      );
  String get plugin => Intl.message(
        "Home.plugin",
        desc: '插件',
      );
  String get selectPlugin => Intl.message(
        "Home.select plugin",
        desc: '選擇插件',
      );
  String get nodata => Intl.message(
        "Home.nodata",
        desc: '沒有找到數據',
      );
}
