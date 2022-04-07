import 'package:sqflite/sqflite.dart';
import './status.dart';
import './helper.dart';

/// 檔案下載記錄
class DownloadFile {
  /// 任務 Download.id
  String id;

  // 索引
  int index;

  /// 任務狀態
  Status status;

  /// 服務器返回的最後修改時間 用於 Accept-Ranges
  String lastModified;

  /// 服務器返回的 hash 用於 Accept-Ranges
  String eTag;

  /// 已下載檔案大小 用於恢復下載
  int offset;

  /// 檔案大小
  int size;

  /// 效驗值 用於恢復下載時驗證數據是否損毀
  String checksum;

  DownloadFile({
    required this.id,
    required this.index,
    required this.status,
    required this.lastModified,
    required this.eTag,
    required this.offset,
    required this.size,
    required this.checksum,
  });
  Map<String, dynamic> toMap() => <String, dynamic>{
        DownloadFileHelper.columnID: id,
        DownloadFileHelper.columnIndex: index,
        DownloadFileHelper.columnStatus: status.value,
        DownloadFileHelper.columnLastModified: lastModified,
        DownloadFileHelper.columnETag: eTag,
        DownloadFileHelper.columnOffset: offset,
        DownloadFileHelper.columnSize: size,
        DownloadFileHelper.columnChecksum: checksum,
      };
  DownloadFile.fromMap(Map<String, dynamic> map)
      : id = map[DownloadFileHelper.columnID] ?? '',
        index = map[DownloadFileHelper.columnIndex] ?? 0,
        status = Status.fromValue(map[DownloadFileHelper.columnStatus]),
        lastModified = map[DownloadFileHelper.columnLastModified] ?? '',
        eTag = map[DownloadFileHelper.columnETag] ?? '',
        offset = map[DownloadFileHelper.columnOffset] ?? 0,
        size = map[DownloadFileHelper.columnSize] ?? 0,
        checksum = map[DownloadFileHelper.columnChecksum] ?? '';
}

class DownloadFileHelper extends Helper<DownloadFile>
    with Executor, HasId, ById<DownloadFile, int> {
  static const table = 'download_file';
  static const columnID = 'id';
  static const columnIndex = '_i';
  static const columnStatus = 'status';
  static const columnLastModified = 'last_modified';
  static const columnETag = 'etag';
  static const columnOffset = 'offset';
  static const columnSize = 'size';
  static const columnChecksum = 'checksum';
  static const columns = [
    columnID,
    columnIndex,
    columnStatus,
    columnLastModified,
    columnETag,
    columnOffset,
    columnSize,
    columnChecksum,
  ];
  static Future<void> onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE IF NOT EXISTS 
$table (
$columnID TEXT DEFAULT '', 
$columnIndex INTEGER DEFAULT 0,
$columnStatus INTEGER DEFAULT 0,
$columnLastModified TEXT DEFAULT '',
$columnETag TEXT DEFAULT '',
$columnOffset INTEGER DEFAULT 0,
$columnSize INTEGER DEFAULT 0,
$columnChecksum TEXT DEFAULT ''
)''');

    await db.execute('''CREATE INDEX IF NOT EXISTS 
index_${columnID}_of_$table
ON $table ($columnID);
''');
  }

  static Future<void> onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    await onCreate(db, newVersion);
  }

  DownloadFileHelper(Database db) : super(db);
  @override
  String get tableName => table;
  @override
  DownloadFile fromMap(Map<String, dynamic> map) => DownloadFile.fromMap(map);
  @override
  Map<String, dynamic> toMap(DownloadFile data, {bool insert = false}) {
    return data.toMap();
  }
}
