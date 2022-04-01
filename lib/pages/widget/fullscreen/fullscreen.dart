import 'package:flutter/material.dart';

class FullscreenState<T> {
  /// 數據源
  final List<T> source;
  final void Function(BuildContext context, FullscreenState<T> self) onChanged;

  /// 當前位置
  int offset;
  FullscreenState({
    required this.source,
    required this.onChanged,
    this.offset = 0,
  });
}
