import 'dart:convert';
import 'dart:math';

import 'package:sqflite/sqflite.dart';
import './helper.dart';
import './status.dart';

/// 下載 任務
class Download {
  /// 任務 uuid
  String id;

  /// 任務所屬的用戶
  int account;

  /// 任務狀態
  Status status;

  /// 相冊 id
  String categorieID;

  /// 相冊 名稱
  String categorieName;

  /// 要下載的檔案 url
  List<String> urls;

  /// 檔案下載名稱
  List<String> names;

  /// 任務出錯時的錯誤信息
  String error;

  Download({
    required this.id,
    required this.account,
    required this.status,
    required this.categorieID,
    required this.categorieName,
    required this.urls,
    required this.names,
    required this.error,
  });
  Map<String, dynamic> toMap() => <String, dynamic>{
        DownloadHelper.columnID: id,
        DownloadHelper.columnAccount: account,
        DownloadHelper.columnStatus: status.value,
        DownloadHelper.columnCategorieID: categorieID,
        DownloadHelper.columnCategorieName: categorieName,
        DownloadHelper.columnUrls: jsonEncode(urls),
        DownloadHelper.columnNames: jsonEncode(names),
        DownloadHelper.columnError: error,
      };
  Download.fromMap(Map<String, dynamic> map)
      : id = map[DownloadHelper.columnID] ?? '',
        account = map[DownloadHelper.columnAccount] ?? 0,
        status = Status.fromValue(map[DownloadHelper.columnStatus] ?? 0),
        categorieID = map[DownloadHelper.columnCategorieID] ?? '',
        categorieName = map[DownloadHelper.columnCategorieName] ?? '',
        urls = <String>[],
        names = <String>[],
        error = map[DownloadHelper.columnError] ?? '' {
    final List l0 = map[DownloadHelper.columnUrls] ?? [];
    final List l1 = map[DownloadHelper.columnNames] ?? [];
    final count = min(l0.length, l1.length);
    for (var i = 0; i < count; i++) {
      urls.add(l0[i]);
      names.add(l1[i]);
    }
  }
}

class DownloadHelper extends Helper<Download>
    with Executor, HasId, ById<Download, int> {
  static const table = 'download';
  static const columnID = 'id';
  static const columnAccount = 'account';
  static const columnStatus = 'status';
  static const columnCategorieID = 'categorie_id';
  static const columnCategorieName = 'categorie_name';
  static const columnUrls = 'urls';
  static const columnNames = 'names';
  static const columnError = 'err';
  static const columns = [
    columnID,
    columnAccount,
    columnStatus,
    columnCategorieID,
    columnCategorieName,
    columnUrls,
    columnNames,
    columnError
  ];
  static Future<void> onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE IF NOT EXISTS 
$table (
$columnID TEXT PRIMARY KEY, 
$columnAccount INTEGER DEFAULT 0,
$columnStatus INTEGER DEFAULT 0,
$columnCategorieID TEXT DEFAULT '',
$columnCategorieName TEXT DEFAULT '',
$columnUrls TEXT DEFAULT '',
$columnNames TEXT DEFAULT '',
$columnError TEXT DEFAULT ''
)''');

    await db.execute('''CREATE INDEX IF NOT EXISTS 
index_${columnAccount}_of_$table
ON $table ($columnAccount);
''');
  }

  static Future<void> onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    await onCreate(db, newVersion);
  }

  DownloadHelper(Database db) : super(db);
  @override
  String get tableName => table;
  @override
  Download fromMap(Map<String, dynamic> map) => Download.fromMap(map);
  @override
  Map<String, dynamic> toMap(Download data, {bool insert = false}) {
    return data.toMap();
  }

  /// 重置 運行狀態到 空閒，這通常由程式初始化時恢復上次異常退出的狀態
  Future<int> reset(int account) async {
    return db.update(
      tableName,
      {columnStatus: Status.idle.value},
      where: '$columnAccount = ? and $columnStatus = ?',
      whereArgs: [account, Status.running.value],
    );
  }

  Future<int> setStatus(String id, Status status) async {
    return db.update(
      tableName,
      {columnStatus: Status.idle.value},
      where: '$columnID = ?',
      whereArgs: [id],
    );
  }
}
