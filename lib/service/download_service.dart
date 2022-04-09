import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:piwigo/db/data/download.dart';
import 'package:piwigo/db/data/download_file.dart';
import 'package:piwigo/db/data/status.dart';
import 'package:piwigo/db/db.dart';
import 'package:piwigo/rpc/webapi/client.dart';
import 'package:piwigo/utils/linked.dart';
import 'package:piwigo/utils/mutex.dart';
import 'package:rxdart/subjects.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;

class Downloadmanager {
  static Downloadmanager? _instance;
  static Downloadmanager get instance => _instance ??= Downloadmanager._();
  Downloadmanager._();

  DownloadService? _service;
  final _mutex = Mutex();
  String? _root;
  Future<String?> getDownloadsDirectory() async {
    if (_root == null) {
      switch (Platform.operatingSystem) {
        case "macos":
        case "windows":
        case "linux":
          final dir = await path_provider.getDownloadsDirectory();
          _root = dir!.path;
          break;
        case "android":
          final dir = await path_provider.getExternalStorageDirectory();
          var fullpath = dir!.path;
          while (fullpath != '/') {
            final name = path.basename(fullpath);
            try {
              final n = int.parse(name);
              if (n >= 0) {
                _root = path.join(fullpath, 'Download');
                return _root;
              }
            } catch (_) {}
            fullpath = path.dirname(fullpath);
          }
          break;
        default:
          return null;
      }
    }
    return _root!;
  }

  Future<DownloadService?> service(Client client) async {
    _mutex.lock();
    try {
      final root = await getDownloadsDirectory();
      if (root == null) {
        return null;
      }
      debugPrint("root=$root");

      var srv = _service;
      if (srv != null) {
        if (srv.client.account == client.account) {
          return srv;
        }
        // 銷毀過期 服務
        _service = null;
        await srv.dispose();
      }
      srv = DownloadService(
        client: client,
      );
      // 執行初始化
      await srv._init(root);

      _service = srv;
      return srv;
    } finally {
      _mutex.unlock();
    }
  }
}

class DownloadService {
  late final String root;
  final Client client;
  final _controller = StreamController<Download>();
  DownloadService({
    required this.client,
  }) {
    _onData();
  }
  late DownloadHelper _downloadHelper;
  late DownloadFileHelper _downloadFileHelper;
  Future<void> _init(String path) async {
    try {
      root = path;
      final helpers = await DB.helpers;
      _downloadHelper = helpers.download;
      _downloadFileHelper = helpers.downloadFile;

      final helper = helpers.download;
      await helper.reset(client.account);

      final list = await helper.query(
        where:
            '${DownloadHelper.columnAccount} = ? and ${DownloadHelper.columnStatus} = ?',
        whereArgs: [client.account, Status.idle.value],
      );

      /// 恢復任務
      for (var item in list) {
        add(item);
      }
    } catch (e) {
      _controller.close();
      rethrow;
    }
  }

  _onData() async {
    await for (var download in _controller.stream) {
      _run(download);
    }
  }

  /// 添加一個任務
  void add(Download download) => _controller.add(download);

  void _run(Download download) {
    final worker = _Worker(
      client: client,
      download: download,
      cancelToken: _cancelToken,
      onChanged: _onChanged,
      onFileChanged: _onFileChanged,
      downloadFileHelper: _downloadFileHelper,
      downloadHelper: _downloadHelper,
    );
    if (_worker == null) {
      _worker = worker;
      _do(worker);
    } else {
      _workers.add(LinkedValue<_Worker>(worker));
    }
  }

  _do(_Worker worker) async {
    try {
      await worker.run();
    } catch (e) {
      worker.download.status = Status.error;
      _onChanged(worker.download);
    }
    _worker = null;
    if (_cancelToken.isCancelled || _workers.isEmpty) {
      return;
    }

    // 繼續下個任務
    final first = _workers.first;
    worker = first.value;
    _workers.remove(first);
    _worker = worker;
    _do(worker);
  }

  final _workers = LinkedList<LinkedValue<_Worker>>();
  _Worker? _worker;
  _onChanged(Download download) => _subject.add(download);
  _onFileChanged(DownloadFile file) => _subjectFile.add(file);
  final _subject = BehaviorSubject<Download>();
  Stream<Download> get stream => _subject.stream;
  final _subjectFile = BehaviorSubject<DownloadFile>();
  Stream<DownloadFile> get streamFile => _subjectFile.stream;

  /// 關閉下載服務 釋放所有資源
  Future<void> dispose() async {
    _controller.close();
    _cancelToken.cancel();
    _subject.close();
    _subjectFile.close();
  }

  final _cancelToken = CancelToken();
}

int _concurrency() {
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    return 8;
  }
  return 4;
}

int _block() {
  int val = 1024 * 1024 * 5; // 5m
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    return val * 4; // 20m
  }
  return val;
}

class _Worker {
  static int concurrency = _concurrency();
  static int block = _block();

  final Client client;
  final Download download;
  final CancelToken cancelToken;
  final ValueChanged<Download> onChanged;
  final ValueChanged<DownloadFile> onFileChanged;
  final DownloadHelper downloadHelper;
  final DownloadFileHelper downloadFileHelper;
  final _files = <DownloadFile>[];
  _Worker({
    required this.client,
    required this.download,
    required this.cancelToken,
    required this.onChanged,
    required this.onFileChanged,
    required this.downloadHelper,
    required this.downloadFileHelper,
  });
  Future setStatus() async {
    try {
      await downloadHelper.setStatus(download.id, download.status);
    } catch (e) {
      debugPrint('downloadHelper.setStatus error: $e');
    }
    onChanged(download);
  }

  Future run() async {
    download.status = Status.running;
    onChanged(download);
    try {
      // 獲取任務列表
      final list = await downloadFileHelper.query(
        where: '${DownloadFileHelper.columnID} = ?',
        whereArgs: [download.id],
      );
      final m = <int, DownloadFile>{};
      for (var item in list) {
        final key = item.index;
        if (m.containsKey(key)) {
          continue;
        }
        m[key] = item;
      }
      for (var i = 0; i < download.names.length; i++) {
        final val = m[i];
        if (val == null) {
          throw Exception('download file not match');
        }
        _files.add(val);
      }
    } catch (e) {
      download.status = Status.error;
      onChanged(download);
    }
  }
}
