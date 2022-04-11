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
    this.onKeySubmit,
    required Widget child,
  })  : widgetBuilder = null,
        widget = child,
        super(key: key);

  const MyKeyboardListener.builder({
    Key? key,
    required this.focusNode,
    this.autofocus = false,
    this.includeSemantics = true,
    this.onKeyEvent,
    this.onKeyTab,
    this.onKeySubmit,
    required WidgetBuilder builder,
  })  : widgetBuilder = builder,
        widget = null,
        super(key: key);

  /// Controls whether this widget has keyboard focus.
  final FocusNode focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// {@macro flutter.widgets.Focus.includeSemantics}
  final bool includeSemantics;

  /// Called whenever this widget receives a keyboard event.
  final ValueChanged<KeyEvent>? onKeyEvent;
  final ValueChanged<KeyEvent>? onKeyTab;

  /// LogicalKeyboardKey.select or LogicalKeyboardKey.enter
  final ValueChanged<KeyEvent>? onKeySubmit;
  // final VoidCallback? onSelected;
  final WidgetBuilder? widgetBuilder;
  final Widget? widget;
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
          if (widget.onKeySubmit != null &&
              (evt.logicalKey == LogicalKeyboardKey.select ||
                  evt.logicalKey == LogicalKeyboardKey.enter)) {
            widget.onKeySubmit!(evt);
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
              widget.onKeySubmit != null)
          ? _onKeyEvent
          : null,
      child: widget.widget ?? widget.widgetBuilder!(context),
    );
  }
}
