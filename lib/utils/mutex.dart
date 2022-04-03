import 'dart:async';

class Mutex {
  Completer<void>? _completer;
  Future<void> lock() async {
    if (_completer != null) {
      await _completer!.future;
    }
    _completer = Completer<void>();
  }

  void unlock() {
    final completer = _completer!;
    _completer = null;
    completer.complete();
  }
}
