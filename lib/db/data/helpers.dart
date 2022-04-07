import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:sqflite/sqflite.dart';
import './datetime.dart';
import './account.dart';
import './download.dart';
import './download_file.dart';

class Helpers {
  final AccountHelper account;
  final DownloadHelper download;
  final DownloadFileHelper downloadFile;
  Helpers(Database db)
      : account = AccountHelper(db),
        download = DownloadHelper(db),
        downloadFile = DownloadFileHelper(db);
  static FutureOr<void> onCreate(Database db, int version) async {
    debugPrint('onCreate: $version');
    await DatetimeHelper.onCreate(db, version);
    await AccountHelper.onCreate(db, version);
    await DownloadHelper.onCreate(db, version);
    await DownloadFileHelper.onCreate(db, version);
  }

  static FutureOr<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    debugPrint('onUpgrade: $oldVersion -> $newVersion');
    await DatetimeHelper.onUpgrade(db, oldVersion, newVersion);
    await AccountHelper.onUpgrade(db, oldVersion, newVersion);
    await DownloadHelper.onUpgrade(db, oldVersion, newVersion);
    await DownloadFileHelper.onUpgrade(db, oldVersion, newVersion);
  }
}
