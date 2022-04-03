import 'dart:io';

import 'package:piwigo/utils/mutex.dart';
import 'package:wakelock/wakelock.dart';

class WakelockService {
  static WakelockService? _instance;
  static WakelockService get instance => _instance ??= WakelockService._();
  WakelockService._();
  bool? _work;

  /// https://pub.dev/packages/wakelock
  bool get isSupported =>
      Platform.isAndroid ||
      Platform.isIOS ||
      Platform.isMacOS ||
      Platform.isWindows;
  void enable() {
    if (isSupported) {
      _work = true;
      _run();
    }
  }

  void disable() {
    if (isSupported) {
      _work = false;
      _run();
    }
  }

  final _mutex = Mutex();
  _run() async {
    bool lock = _mutex.tryLock();
    if (!lock) {
      return false;
    }
    try {
      while (_work != null) {
        final work = _work!;
        _work = null;
        if (work) {
          await Wakelock.enable();
        } else {
          await Wakelock.disable();
        }
      }
    } finally {
      _mutex.unlock();
    }
  }
}
