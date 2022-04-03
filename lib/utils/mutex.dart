import 'dart:async';

class Mutex {
  Completer<void>? _completer;
  Future<void> lock() async {
    if (_completer != null) {
      await _completer!.future;
    }
    _completer = Completer<void>();
  }

  bool tryLock() {
    if (_completer != null) {
      return false;
    }
    _completer = Completer<void>();
    return true;
  }

  void unlock() {
    final completer = _completer!;
    _completer = null;
    completer.complete();
  }
}
