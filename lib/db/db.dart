import 'dart:async';
import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import './data/helpers.dart';

/// 定義 static class 用於管理數據庫創建
class DB {
  DB._();
  static const name = 'my.db';
  static const version = 3;

  /// 初始化 ffi
  static Future<void> _ffiInit() async {
    if (databaseFactory == databaseFactoryFfi) {
      return;
    }
    if (Platform.isWindows || Platform.isLinux) {
      // Initialize FFI
      sqfliteFfiInit();
    } else {
      databaseFactoryFfi.setDatabasesPath(await getDatabasesPath());
    }
    databaseFactory = databaseFactoryFfi;
  }

  static Completer<Helpers>? _completer;

  /// 返回數據庫操作 helper
  static Future<Helpers> get helpers async {
    if (_completer == null) {
      final completer = Completer<Helpers>();
      _completer = completer; // 保證同時只有一 future 執行數據庫初始化

      try {
        await _ffiInit(); // 初始化 ffi

        final db = await openDatabase(
          name,
          version: version,
          onCreate: (Database db, int version) => Helpers.onCreate(db, version),
          onUpgrade: (Database db, int oldVersion, int newVersion) =>
              Helpers.onUpgrade(db, oldVersion, newVersion),
        );
        debugPrint("db helper ready");
        completer.complete(Helpers(db));
      } catch (e) {
        debugPrint("db init error : $e");
        _completer = null; // 重置 _completer 以便可以再次執行數據庫初始化
        completer.completeError(e);
        return completer.future;
      }
    }
    return _completer!.future;
  }
}
