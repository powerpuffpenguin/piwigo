import 'package:flutter/material.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/download/source.dart';
import 'package:piwigo/pages/widget/listener/keyboard_listener.dart';
import 'package:piwigo/pages/widget/state.dart';
import 'package:piwigo/rpc/webapi/client.dart';

class MyDownloadPage extends StatefulWidget {
  const MyDownloadPage({
    Key? key,
    required this.client,
    required this.source,
  }) : super(key: key);
  final Client client;
  final Source? source;
  @override
  _MyDownloadPageState createState() => _MyDownloadPageState();
}

abstract class _DownloadPageState extends MyState<MyDownloadPage> {
  Client get client => widget.client;
  Source? get source => widget.source;
}

class _MyDownloadPageState extends _DownloadPageState with _KeyboardComponent {
  @override
  Widget build(BuildContext context) {
    return MyKeyboardListener(
      focusNode: createFocusNode('MyKeyboardListener'),
      child: _build(context),
    );
  }

  Widget _build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).photo.download),
        leading: backOfAppBar(
          context,
        ),
      ),
    );
  }
}

mixin _KeyboardComponent on _DownloadPageState {}
