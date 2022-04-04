import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RowBuilder extends StatelessWidget {
  const RowBuilder(
      {Key? key,
      required this.start,
      required this.end,
      required this.itemBuilder})
      : super(key: key);
  final int start;
  final int end;
  final IndexedWidgetBuilder itemBuilder;
  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = start; i < end; i++) {
      children.add(itemBuilder(context, i));
    }
    return Row(
      children: children,
    );
  }
}
