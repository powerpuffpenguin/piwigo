import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyKeyboardListener extends StatefulWidget {
  const MyKeyboardListener({
    Key? key,
    required this.focusNode,
    this.autofocus = false,
    this.includeSemantics = true,
    this.onKeyEvent,
    this.onKeyTab,
    this.onSelected,
    required this.builder,
  }) : super(key: key);

  /// Controls whether this widget has keyboard focus.
  final FocusNode focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// {@macro flutter.widgets.Focus.includeSemantics}
  final bool includeSemantics;

  /// Called whenever this widget receives a keyboard event.
  final ValueChanged<KeyEvent>? onKeyEvent;
  final ValueChanged<KeyEvent>? onKeyTab;
  final VoidCallback? onSelected;
  final WidgetBuilder builder;
  @override
  _MyKeyboardListenerState createState() => _MyKeyboardListenerState();
}

class _MyKeyboardListenerState extends State<MyKeyboardListener> {
  LogicalKeyboardKey? _lastDown;
  _onKeyEvent(KeyEvent evt) {
    if (widget.onKeyEvent != null) {
      widget.onKeyEvent!(evt);
    }

    if (evt is KeyDownEvent) {
      _lastDown = evt.logicalKey;
    } else {
      if (evt is KeyUpEvent) {
        if (evt.logicalKey == _lastDown) {
          if (widget.onKeyTab != null) {
            widget.onKeyTab!(evt);
          }
          if (widget.onSelected != null &&
              evt.logicalKey == LogicalKeyboardKey.select) {
            widget.onSelected!();
          }
        }
      }
      _lastDown = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      includeSemantics: widget.includeSemantics,
      onKeyEvent: (widget.onKeyEvent != null ||
              widget.onKeyTab != null ||
              widget.onSelected != null)
          ? _onKeyEvent
          : null,
      child: widget.builder(context),
    );
  }
}
