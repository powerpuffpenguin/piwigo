import 'package:flutter/material.dart';
import 'package:piwigo/db/data/account.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/widget/drawer.dart';
import 'package:piwigo/rpc/webapi/client.dart';
import 'package:ppg_ui/ppg_ui.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
    required this.client,
  }) : super(key: key);
  final Client client;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends UIState<MyHomePage> {
  Client get client => widget.client;
  bool _inited = false;
  dynamic _error;
  @override
  void initState() {
    super.initState();
    if (client.status == null) {
      _init().then((_) {
        if (isNotClosed) {
          _getlist();
        }
      });
    } else {
      _inited = true;
      _getlist();
    }
  }

  Future<void> _init() async {
    setState(() {
      disabled = true;
      _error = null;
    });
    try {
      if (client.name.isNotEmpty) {
        await client.login();
      }
      final status = await client.getStatus();
      client.status = status;

      _getlist();
    } catch (e) {
      aliveSetState(() {
        disabled = false;
        _error = e;
      });
    }
  }

  _getlist() {
    if (enabled || _error != null) {
      setState(() {
        disabled = true;
        _error = null;
      });
    }
    try {
      aliveSetState(() {
        disabled = false;
      });
    } catch (e) {
      aliveSetState(() {
        disabled = false;
        _error = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawerView(
        client: client,
        disabled: disabled,
      ),
      appBar: AppBar(
        title: Text(S.of(context).appName),
      ),
    );
  }
}
