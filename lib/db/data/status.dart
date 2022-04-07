import 'package:piwigo/utils/enum.dart';

/// 任務狀態
class Status extends Enum {
  final bool unknow;
  const Status._(
    int value,
    String name, {
    this.unknow = false,
  }) : super(value, name);

  /// 未執行
  static const idle = Status._(1, 'idle');

  // 正在被執行中
  static const running = Status._(2, 'running');

  /// 被暫停執行
  static const pause = Status._(3, 'pause');

  /// 執行錯誤
  static const error = Status._(4, 'error');

  /// 執行成功
  static const success = Status._(5, 'success');
  static const values = <Status>[idle, running, pause, error, success];
  static Status fromValue(int val) {
    for (var value in values) {
      if (val == value.value) {
        return value;
      }
    }
    return Status._(val, 'unknow-$val', unknow: true);
  }
}
