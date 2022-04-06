import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piwigo/db/data/account.dart';
import 'package:piwigo/db/db.dart';
import 'package:piwigo/db/settings.dart';
import 'package:piwigo/environment.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/home/home.dart';
import 'package:piwigo/pages/load/add.dart';
import 'package:piwigo/pages/widget/listener/keyboard_listener.dart';
import 'package:piwigo/pages/widget/spin.dart';
import 'package:piwigo/pages/widget/state.dart';
import 'package:piwigo/rpc/webapi/client.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({
    Key? key,
  }) : super(key: key);
  @override
  _MyAccountPageState createState() => _MyAccountPageState();
}

class _MyAccountPageState extends MyState<MyAccountPage> {
  final _source = <Account>[];
  dynamic _error;
  int _account = -1;
  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    if (_error != null && enabled) {
      setState(() {
        _error = null;
        disabled = true;
      });
    }
    try {
      final account = await MySettings.instance.getAccount();
      checkAlive();
      final helper = (await DB.helpers).account;
      checkAlive();
      final source = await helper.query();
      aliveSetState(() {
        _account = account;
        disabled = false;
        _source.addAll(source);
      });
    } catch (e) {
      aliveSetState(() {
        disabled = false;
        _error = e;
      });
    }
  }

  _delete(Account account) async {
    setState(() {
      disabled = true;
    });
    try {
      final helper = (await DB.helpers).account;
      checkAlive();
      await helper.deleteById(account.id);
      aliveSetState(() {
        disabled = false;
        for (var i = 0; i < _source.length; i++) {
          if (_source[i].id == account.id) {
            _source.removeAt(i);
            break;
          }
        }
      });
    } catch (e) {
      aliveSetState(() {
        disabled = false;
        BotToast.showText(text: '$e');
      });
    }
  }

  void _openHome(Account account) {
    final client = Client(
      baseUrl: account.url,
      name: account.name,
      password: account.password,
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MyHomePage(
          client: client,
        ),
      ),
      (_) => false,
    );
  }

  void _openEdit(Account account) {
    Navigator.of(context)
        .push<Account>(
      MaterialPageRoute(
        builder: (_) => MyAddPage(
          account: account,
        ),
      ),
    )
        .then((account) {
      if (account != null && isNotClosed) {
        setState(() {
          account.name = account.name;
          account.url = account.url;
        });
      }
    });
  }

  void _openNew() {
    Navigator.of(context)
        .push<Account>(
      MaterialPageRoute(
        builder: (_) => const MyAddPage(),
      ),
    )
        .then((account) {
      if (account != null && isNotClosed) {
        setState(() {
          _source.add(account);
        });
      }
    });
  }

  String _getName(String name) => name.isEmpty ? 'guest' : name;

  void _openDelete(Account account) {
    showDialog(
      context: context,
      builder: (context) => _DeleteDialog(
        child: Text('${_getName(account.name)} of ${account.url}'),
      ),
    ).then((ok) {
      if (isNotClosed && (ok ?? false)) {
        _delete(account);
      }
    });
  }

  _onSelected() {
    final data = focusedNode()?.data;
    if (data is _SelectAction) {
      switch (data.what) {
        case _ActionType.openAdd:
          _openNew();
          break;
        case _ActionType.openEdit:
          // _openEdit(data.data!);
          _openHome(data.data!);
          break;
        case _ActionType.arrowBack:
          Navigator.of(context).pop();
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backOfAppBar(
          context,
          data: const _SelectAction(what: _ActionType.arrowBack),
        ),
        title: Text(S.of(context).account.manage),
      ),
      body: _error == null ? _buildBody(context) : buildError(context, _error),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget? _buildBody(BuildContext context) {
    return MyKeyboardListener(
      onKeyTab: disabled
          ? null
          : (evt) {
              if (evt.logicalKey == LogicalKeyboardKey.select ||
                  evt.logicalKey == LogicalKeyboardKey.enter) {
                _onSelected();
              } else if (evt.logicalKey == LogicalKeyboardKey.arrowLeft ||
                  evt.logicalKey == LogicalKeyboardKey.arrowRight) {
                final data = focusedNode()?.data;
                if (data is _SelectAction &&
                    data.what == _ActionType.openEdit) {
                  if (evt.logicalKey == LogicalKeyboardKey.arrowLeft) {
                    _openDelete(data.data!);
                  } else {
                    _openEdit(data.data!);
                  }
                }
              }
            },
      focusNode: createFocusNode('MyKeyboardListener'),
      child: _buildView(context),
    );
  }

  Widget _buildView(BuildContext context) {
    return ListView(
      children: _source.map<Widget>(
        (node) {
          final name = _getName(node.name);
          var title = MyEnvironment.isDebug ? '$name ${node.id}' : name;
          return FocusScope(
            autofocus: true,
            node: focusScopeNode,
            child: ListTile(
              focusNode: createFocusNode(
                node.id.toString(),
                data: _SelectAction(
                  what: _ActionType.openEdit,
                  data: node,
                ),
              ),
              leading: node.id == _account
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).indicatorColor,
                    )
                  : const Icon(Icons.person_pin),
              title: Text(title),
              subtitle: Text(node.url),
              trailing: IconButton(
                tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                icon: const Icon(Icons.delete),
                onPressed: disabled ? null : () => _openDelete(node),
              ),
              onTap: disabled ? null : () => _openHome(node),
              onLongPress: disabled ? null : () => _openEdit(node),
            ),
          );
        },
      ).toList(),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    if (disabled) {
      return createSpinFloating();
    }
    if (_error != null) {
      return FloatingActionButton(
        tooltip: S.of(context).app.refresh,
        child: const Icon(Icons.refresh),
        onPressed: disabled ? null : _init,
      );
    }
    return FocusScope(
      node: focusScopeNode,
      child: FloatingActionButton(
        focusNode: createFocusNode(
          'FloatingActionButton',
          data: const _SelectAction(what: _ActionType.openAdd),
        ),
        tooltip: S.of(context).account.add,
        child: const Icon(Icons.add),
        onPressed: disabled ? null : _openNew,
      ),
    );
  }
}

enum _ActionType {
  arrowBack,
  openAdd,
  openEdit,
}

class _SelectAction {
  const _SelectAction({required this.what, this.data});
  final _ActionType what;
  final Account? data;
}

class _DeleteDialog extends StatefulWidget {
  const _DeleteDialog({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;
  @override
  _DeleteDialogState createState() => _DeleteDialogState();
}

class _DeleteDialogState extends MyState<_DeleteDialog> {
  @override
  Widget build(BuildContext context) {
    return MyKeyboardListener(
      onSelected: () {
        final data = focusedNode()?.data;
        if (data is bool) {
          Navigator.of(context).pop(data);
        }
      },
      focusNode: createFocusNode('MyKeyboardListener'),
      child: AlertDialog(
        title: Text(S.of(context).account.delete),
        content: SingleChildScrollView(
          child: widget.child,
        ),
        actions: <Widget>[
          FocusScope(
            autofocus: true,
            node: focusScopeNode,
            child: TextButton(
              focusNode: createFocusNode('true', data: true),
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ),
          FocusScope(
            node: focusScopeNode,
            child: TextButton(
              focusNode: createFocusNode('false', data: false),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ),
        ],
      ),
    );
  }
}
