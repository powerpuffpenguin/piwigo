// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef FocusableOnMove = KeyEventResult Function(
    FocusNode focusNode, KeyEvent event, TraversalDirection traversalDirection);
typedef FocusableOnOK = KeyEventResult Function(
    FocusNode focusNode, KeyEvent event);
typedef FocusableOnCancel = FocusableOnOK;

typedef FocusBuilderCallback = Widget Function(
    BuildContext context, FocusNode focusNode);

enum WhenKeyEvent {
  /// 任何時候都不要處理
  none,

  /// 當按鍵按下時
  down,

  /// 當按鍵擡起時
  up,

  /// down or up
  all,
}

class FocusableWidget extends StatefulWidget {
  const FocusableWidget({
    Key? key,
    required this.child,
    this.focusNode,
    this.onKeyEvent,
    this.onMove,
    this.whenMove = WhenKeyEvent.down,
    this.onOK,
    this.whenOk = WhenKeyEvent.up,
    this.onCancel,
    this.whenCancel = WhenKeyEvent.none,
  }) : super(key: key);

  /// 被包裝的 Widget
  final Widget child;
  final FocusNode? focusNode;

  /// 可以攔截默認的 按鍵處理
  final FocusOnKeyEventCallback? onKeyEvent;

  /// 可以攔截默認的 焦點移動 處理
  final FocusableOnMove? onMove;
  final WhenKeyEvent whenMove;

  /// 可以攔截默認的 確認 處理
  final FocusableOnOK? onOK;
  final WhenKeyEvent whenOk;

  /// 可以攔截默認的 取消 處理
  final FocusableOnCancel? onCancel;
  final WhenKeyEvent whenCancel;

  @override
  createState() => _FocusableWidgetState();
}

class _FocusableWidgetState extends State<FocusableWidget> {
  FocusNode? _focusNode;

  /// 如果 widget 沒設置 FocusNode 就創建一個
  FocusNode get focusNode {
    if (widget.focusNode != null) {
      return widget.focusNode!;
    }
    return _focusNode ??= FocusNode();
  }

  @override
  void dispose() {
    /// 釋放自動創建的 FocusNode
    _focusNode?.dispose();
    super.dispose();
  }

  KeyEventResult _onKeyEvent(FocusNode focusNode, KeyEvent event) {
    /// 首先調用 傳入的 攔截器
    if (widget.onKeyEvent != null) {
      final result = widget.onKeyEvent!(focusNode, event);
      if (result != KeyEventResult.ignored) {
        return result;
      }
    }

    // tv 遙控器 移動 焦點
    // 鍵盤 方向鍵
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      return _moveArrow(focusNode, event, TraversalDirection.left);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      return _moveArrow(focusNode, event, TraversalDirection.right);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      return _moveArrow(focusNode, event, TraversalDirection.up);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      return _moveArrow(focusNode, event, TraversalDirection.down);
    } else if (event.logicalKey == LogicalKeyboardKey.select) {
      return _ok(focusNode, event);
    } else if (event.logicalKey == LogicalKeyboardKey.cancel) {
      return _cancel(focusNode, event);
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _moveArrow(
      FocusNode node, KeyEvent event, TraversalDirection direction) {
    if (widget.onMove != null) {
      switch (widget.whenMove) {
        case WhenKeyEvent.down:
          if (event is! KeyDownEvent) {
            return KeyEventResult.ignored;
          }
          break;
        case WhenKeyEvent.up:
          if (event is! KeyUpEvent) {
            return KeyEventResult.ignored;
          }
          break;
        case WhenKeyEvent.all:
          break;
        default:
          return KeyEventResult.ignored;
      }

      final result = widget.onMove!(node, event, direction);
      if (result != KeyEventResult.ignored) {
        return result;
      }
    }
    // node.focusInDirection(direction);
    // return KeyEventResult.handled;
    return KeyEventResult.ignored;
  }

  KeyEventResult _ok(FocusNode node, KeyEvent event) {
    switch (widget.whenOk) {
      case WhenKeyEvent.down:
        if (event is! KeyDownEvent) {
          return KeyEventResult.ignored;
        }
        break;
      case WhenKeyEvent.up:
        if (event is! KeyUpEvent) {
          return KeyEventResult.ignored;
        }
        break;
      case WhenKeyEvent.all:
        break;
      default:
        return KeyEventResult.ignored;
    }

    if (widget.onOK != null) {
      final result = widget.onOK!(node, event);
      if (result != KeyEventResult.ignored) {
        return result;
      }
    }
    if (node.context?.widget == null) {
      return KeyEventResult.ignored;
    }
    return widgetSubmit(node.context!.widget);
  }

  KeyEventResult _cancel(FocusNode node, KeyEvent event) {
    switch (widget.whenCancel) {
      case WhenKeyEvent.down:
        if (event is! KeyDownEvent) {
          return KeyEventResult.ignored;
        }
        break;
      case WhenKeyEvent.up:
        if (event is! KeyUpEvent) {
          return KeyEventResult.ignored;
        }
        break;
      case WhenKeyEvent.all:
        break;
      default:
        return KeyEventResult.ignored;
    }

    if (widget.onCancel != null) {
      final result = widget.onCancel!(node, event);
      if (result != KeyEventResult.ignored) {
        return result;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    /// 使用 Focus 進行包裝 以便接管鍵盤處理
    final node = focusNode;
    return Focus(
      child: widget.child,
      onFocusChange: ((ok) {
        if (ok && node.hasPrimaryFocus) {
          /// 如果獲取到焦點並有主焦點，將主焦點設置到第一個找到的子焦點(即 被包裝的 widget)
          /// 因爲 flutter 提供的 widget 很多要獲取到主焦點才會額外繪製焦點效果
          for (var child in node.children) {
            if (child.canRequestFocus) {
              child.requestFocus();
              break;
            }
          }
        }
      }),
      focusNode: node,
      onKeyEvent: _onKeyEvent,
    );
  }
}

KeyEventResult widgetSubmit(Widget w) {
  while (w is Focus) {
    w = w.child;
  }
  VoidCallback? submit;

  /// 處理 系統提供的 常用 widget
  if (w is ListTile) {
    submit = w.onTap;
  } else if (w is GestureDetector) {
    submit = w.onTap;
  } else if (w is InkResponse) {
    submit = w.onTap;
  } else if (w is ButtonStyleButton) {
    // TextButton
    submit = w.onPressed;
  } else if (w is IconButton) {
    submit = w.onPressed;
  } else if (w is CloseButton) {
    submit = w.onPressed;
  } else if (w is BackButton) {
    submit = w.onPressed;
  } else if (w is FloatingActionButton) {
    submit = w.onPressed;
  } else {
    return KeyEventResult.ignored;
  }
  if (submit != null) {
    submit();
  }
  return KeyEventResult.handled;
}
