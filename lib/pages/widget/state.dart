import 'package:flutter/material.dart';
import 'package:ppg_ui/state/state.dart';

class MyFocusNode {
  final String id;
  FocusNode focusNode;
  dynamic data;
  MyFocusNode({required this.id, required this.focusNode, this.data});
  void dispose() {
    focusNode.dispose();
  }

  bool get isArrowBack => id == arrowBack;

  static const openDrawer = 'openDrawer';
  static const arrowBack = 'arrow_back';
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
    final add = MyFocusNode(id: id, focusNode: FocusNode(), data: data);
    _keysFocusNode[id] = add;
    _focusNodeKeys[add.focusNode] = add;
    return add.focusNode;
  }

  @protected
  MyFocusNode? focusedNode() {
    if (focusScopeNode.hasFocus) {
      return _focusNodeKeys[focusScopeNode.focusedChild];
    }
    return null;
  }

  @protected
  void nextFocus(String id) {
    final focus = _keysFocusNode[id]?.focusNode;
    if (focus?.canRequestFocus ?? false) {
      focus!.requestFocus();
    }
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

  @protected
  Widget? backOfAppBar(BuildContext context, {dynamic data}) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;
    if (!canPop) {
      return null;
    }
    return FocusScope(
      node: focusScopeNode,
      child: IconButton(
        focusNode: createFocusNode(
          MyFocusNode.arrowBack,
          data: data,
        ),
        icon: const Icon(Icons.arrow_back),
        iconSize: 24,
        onPressed: () => Navigator.of(context).pop(),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      ),
    );
  }

  @protected
  Widget openDrawerOfAppBar(BuildContext context, {dynamic data}) {
    return FocusScope(
      node: focusScopeNode,
      child: Builder(
        builder: (context) => IconButton(
          focusNode: createFocusNode(
            MyFocusNode.openDrawer,
            data: data,
          ),
          icon: const Icon(Icons.menu),
          iconSize: 24,
          onPressed: () => Scaffold.of(context).openDrawer(),
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        ),
      ),
    );
  }
}
