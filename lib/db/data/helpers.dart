import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:sqflite/sqflite.dart';
import './datetime.dart';
import './account.dart';

class Helpers {
  final AccountHelper account;
  Helpers(Database db) : account = AccountHelper(db);
  static FutureOr<void> onCreate(Database db, int version) async {
    debugPrint('onCreate: $version');
    await DatetimeHelper.onCreate(db, version);
    await AccountHelper.onCreate(db, version);
  }

  static FutureOr<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    debugPrint('onUpgrade: $oldVersion -> $newVersion');
    await DatetimeHelper.onUpgrade(db, oldVersion, newVersion);
    await AccountHelper.onUpgrade(db, oldVersion, newVersion);
  }
}
