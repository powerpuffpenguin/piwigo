import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/home/view.dart';
import 'package:piwigo/pages/widget/cover.dart';
import 'package:piwigo/pages/widget/drawer.dart';
import 'package:piwigo/pages/widget/spin.dart';
import 'package:piwigo/rpc/webapi/categories.dart';
import 'package:piwigo/rpc/webapi/client.dart';
import 'package:ppg_ui/ppg_ui.dart';

Client? gclient;

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
  Client get client => gclient ?? widget.client;
  bool _inited = false;
  dynamic _error;
  final _source = <Categorie>[];
  final _cancelToken = CancelToken();
  @override
  void initState() {
    gclient = client;
    super.initState();
    if (client.status == null) {
      _init().then((ok) {
        if (ok && isNotClosed) {
          _getlist();
        }
      });
    } else {
      _inited = true;
      _getlist();
    }
  }

  @override
  void dispose() {
    _cancelToken.cancel();
    if (client.status != null) {
      client.logout();
    }
    super.dispose();
  }

  Future<bool> _init() async {
    setState(() {
      disabled = true;
      _error = null;
    });
    try {
      if (client.name.isNotEmpty) {
        await client.login(cancelToken: _cancelToken);
        checkAlive();
      }
      final status = await client.getStatus(cancelToken: _cancelToken);
      checkAlive();
      client.status = status;
      return true;
    } catch (e) {
      aliveSetState(() {
        disabled = false;
        _error = e;
        debugPrint('$_error');
      });
    }
    return false;
  }

  _getlist() async {
    if (enabled || _error != null || !_inited) {
      setState(() {
        disabled = true;
        _error = null;
        _inited = true;
      });
    }
    try {
      final list = await client.getCategoriesList(cancelToken: _cancelToken);
      aliveSetState(() {
        _source
          ..clear()
          ..addAll(list);
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
      body: _error == null
          ? _buildBody(context)
          : Text(
              "$_error",
              style: TextStyle(color: Theme.of(context).errorColor),
            ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget? _buildBody(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const spacing = 8.0;
    final width = MyCover.calculateWidth(size.width - spacing * 2, spacing);
    final height = MyCover.calculateHeight(width);
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: spacing, bottom: spacing),
        child: Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: _source.map<Widget>((node) {
            var text = S.of(context).home.countPhoto(node.images);
            if (node.categories > 0 && node.categories >= node.images) {
              text += S
                  .of(context)
                  .home
                  .countPhotoInSub(node.categories - node.images);
            }
            return GestureDetector(
              onTap: disabled
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MyViewPage(
                            client: client,
                            categorie: node,
                          ),
                        ),
                      );
                    },
              child: MyCover(
                width: width,
                height: height,
                src: node.cover,
                title: node.name,
                text: text,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    if (disabled) {
      return createSpinFloating();
    } else if (_error != null) {
      return FloatingActionButton(
        child: const Icon(Icons.refresh),
        tooltip: S.of(context).app.refresh,
        onPressed: _inited ? _getlist : _init,
      );
    }
    return null;
  }
}
