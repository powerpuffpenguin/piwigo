import 'package:sqflite/sqflite.dart';
import './helper.dart';

/// 帳戶
class Account {
  int id;
  String url;
  String name;
  String password;
  Account({
    required this.id,
    required this.url,
    required this.name,
    required this.password,
  });
  Map<String, dynamic> toMap() => <String, dynamic>{
        AccountHelper.columnID: id,
        AccountHelper.columnURL: url,
        AccountHelper.columnName: name,
        AccountHelper.columnPassword: password,
      };
  Account.fromMap(Map<String, dynamic> map)
      : id = map[AccountHelper.columnID] ?? 0,
        url = map[AccountHelper.columnURL] ?? '',
        name = map[AccountHelper.columnName] ?? '',
        password = map[AccountHelper.columnPassword] ?? '';
}

class AccountHelper extends Helper<Account>
    with Executor, HasId, HasName, ById<Account, int>, ByName<Account, String> {
  static const table = 'account';
  static const columnID = 'id';
  static const columnURL = 'url';
  static const columnName = 'name';
  static const columnPassword = 'password';
  static const columns = [
    columnID,
    columnURL,
    columnName,
    columnPassword,
  ];
  static Future<void> onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE IF NOT EXISTS 
$table (
$columnID INTEGER PRIMARY KEY AUTOINCREMENT, 
$columnURL TEXT DEFAULT '',
$columnName TEXT DEFAULT '',
$columnPassword TEXT DEFAULT ''
)''');
  }

  static Future<void> onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    await onCreate(db, newVersion);
  }

  AccountHelper(Database db) : super(db);
  @override
  String get tableName => table;
  @override
  Account fromMap(Map<String, dynamic> map) => Account.fromMap(map);
  @override
  Map<String, dynamic> toMap(Account data, {bool insert = false}) {
    final m = data.toMap();
    if (insert) {
      m.remove(columnID);
    }
    return m;
  }
}
