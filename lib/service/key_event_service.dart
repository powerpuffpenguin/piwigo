import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/subjects.dart';

/// 全局鍵盤 用於 快捷鍵 和 適配電視
class KeyEventService {
  static KeyEventService? _instance;
  static KeyEventService get instance => _instance ??= KeyEventService._();
  KeyEventService._();
  final _subject = PublishSubject<KeyEvent>();

  Stream<KeyEvent> get keyUp =>
      _subject.stream.where((evt) => evt is KeyUpEvent);

  void add(KeyEvent evt) {
    debugPrint("*********** add ${evt.runtimeType}");
    debugPrint("***********  $evt");
    _subject.add(evt);
  }
}
