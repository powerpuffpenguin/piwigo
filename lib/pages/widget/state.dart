import 'package:flutter/material.dart';
import 'package:ppg_ui/state/state.dart';

class MyFocusNode {
  FocusNode focusNode;
  dynamic data;
  MyFocusNode({required this.focusNode, this.data});
  void dispose() {
    focusNode.dispose();
  }
}

abstract class MyState<T extends StatefulWidget> extends UIState<T> {
  final _keysFocusNode = <String, MyFocusNode>{};
  final _focusNodeKeys = <FocusNode, MyFocusNode>{};
  final FocusScopeNode focusScopeNode = FocusScopeNode();

  @protected
  MyFocusNode? getFocusNode(String id) => _keysFocusNode[id];
  @protected
  FocusNode createFocusNode(String id, {dynamic data}) {
    final focusNode = _keysFocusNode[id];
    if (focusNode != null) {
      if (focusNode.data != data) {
        focusNode.data = data;
      }

      return focusNode.focusNode;
    }
    final add = MyFocusNode(focusNode: FocusNode(), data: data);
    _keysFocusNode[id] = add;
    _focusNodeKeys[add.focusNode] = add;
    return add.focusNode;
  }

  MyFocusNode? focusedNode() {
    if (focusScopeNode.hasFocus) {
      return _focusNodeKeys[focusScopeNode.focusedChild];
    }
    return null;
  }

  @mustCallSuper
  @override
  void dispose() {
    _keysFocusNode.forEach((key, value) {
      value.dispose();
    });
    focusScopeNode.dispose();
    super.dispose();
  }
}
