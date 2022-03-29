import 'package:intl/intl.dart';

class Account {
  const Account();
  String get manage => Intl.message(
        'Account.manage',
        desc: '管理帳戶 Manage Accounts',
      );
  String get add => Intl.message(
        'Account.add',
        desc: '添加帳戶 按鈕/提示文本/標題',
      );
  String get edit => Intl.message(
        'Account.edit',
        desc: '編輯帳戶 按鈕/提示文本/標題',
      );
  String get url => Intl.message(
        'Account.url',
        desc: '網址',
      );
  String get name => Intl.message(
        'Account.name',
        desc: '用戶名',
      );
  String get password => Intl.message(
        'Account.password',
        desc: '密碼',
      );
}
