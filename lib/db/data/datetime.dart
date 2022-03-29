import 'package:sqflite/sqflite.dart';

///  映射表結構到 dart
class Datetime {
  int? id;

  /// 創建時間
  DateTime? created;

  /// 最後修改時間
  DateTime? last;

  Datetime({
    this.id,
    this.created,
    this.last,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
        DatetimeHelper.columnID: id,
        DatetimeHelper.columnCreated:
            created?.toUtc().millisecondsSinceEpoch ?? 0,
        DatetimeHelper.columnLast: last?.toUtc().millisecondsSinceEpoch ?? 0,
      };

  Datetime.fromMap(Map<String, dynamic> map) {
    id = map[DatetimeHelper.columnID];
    var v = map[DatetimeHelper.columnCreated];
    if (v is int && v > 0) {
      created = DateTime.fromMillisecondsSinceEpoch(v, isUtc: true).toLocal();
    }
    v = map[DatetimeHelper.columnLast];
    if (v is int && v > 0) {
      last = DateTime.fromMillisecondsSinceEpoch(v, isUtc: true).toLocal();
    }
  }
}

/// helper 提供對表操作函數
class DatetimeHelper {
  static const table = 'date_time';
  static const columnID = 'id';
  static const columnCreated = 'created';
  static const columnLast = 'last';
  static const columns = [
    columnID,
    columnCreated,
    columnLast,
  ];
  static Future<void> onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE IF NOT EXISTS 
$table (
$columnID INTEGER PRIMARY KEY, 
$columnCreated INTEGER DEFAULT 0,
$columnLast INTEGER DEFAULT 0
)''');
  }

  static Future<void> onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    await onCreate(db, newVersion);
  }

  static Future<int> update<T extends DatabaseExecutor>(
    DatabaseExecutor db,
    Datetime datetime,
  ) {
    return db.insert(
      table,
      datetime.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Datetime?> getByID(DatabaseExecutor db, int id) async {
    final list = await db.query(
      table,
      columns: columns,
      where: '$columnID = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (list.isNotEmpty) {
      return Datetime.fromMap(list.first);
    }
    return null;
  }

  static Future<int> deleteByID(DatabaseExecutor db, int id) {
    return db.delete(
      table,
      where: '$columnID = ?',
      whereArgs: [id],
    );
  }
}
