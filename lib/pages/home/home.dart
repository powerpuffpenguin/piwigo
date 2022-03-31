import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/home/view.dart';
import 'package:piwigo/pages/widget/cover.dart';
import 'package:piwigo/pages/widget/drawer.dart';
import 'package:piwigo/pages/widget/spin.dart';
import 'package:piwigo/rpc/webapi/categories.dart';
import 'package:piwigo/rpc/webapi/client.dart';
import 'package:piwigo/utils/wrap.dart';
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
    if (_source.isEmpty) {
      return null;
    }
    final size = MediaQuery.of(context).size;
    const spacing = 8.0;
    final wrap = MyCover.calculateWrap(size, spacing, _source.length);

    return ListView.builder(
      itemCount: _source.length,
      itemBuilder: (context, index) =>
          _buildCategories(context, wrap: wrap, index: index),
    );
  }

  Widget _buildCategories(
    BuildContext context, {
    required MyWrap wrap,
    required int index,
  }) {
    final start = index * wrap.cols;
    var end = start + wrap.cols;
    if (end > _source.length) {
      end = _source.length;
    }
    final range = _source.getRange(start, end);
    var first = true;
    return Container(
      padding: EdgeInsets.only(left: wrap.spacing, right: wrap.spacing),
      alignment: Alignment.topCenter,
      child: Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.only(top: wrap.spacing),
        width: wrap.viewWidth,
        child: Row(
          children: range.map<Widget>((node) {
            var text = S.of(context).home.countPhoto(node.images);
            if (node.categories > 0 && node.categories >= node.images) {
              text += S
                  .of(context)
                  .home
                  .countPhotoInSub(node.categories - node.images);
            }
            EdgeInsetsGeometry? padding;
            if (first) {
              first = false;
            } else {
              padding = EdgeInsets.only(left: wrap.spacing);
            }
            return Container(
              padding: padding,
              child: GestureDetector(
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
                  src: node.cover,
                  title: node.name,
                  text: text,
                  width: wrap.width,
                  height: wrap.height,
                ),
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
