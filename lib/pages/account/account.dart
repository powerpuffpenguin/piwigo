import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piwigo/db/data/account.dart';
import 'package:piwigo/db/db.dart';
import 'package:piwigo/db/settings.dart';
import 'package:piwigo/environment.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/dialog/confirmation_dialog.dart';
import 'package:piwigo/pages/home/home.dart';
import 'package:piwigo/pages/load/add.dart';
import 'package:piwigo/pages/widget/spin.dart';
import 'package:piwigo/pages/widget/state.dart';
import 'package:piwigo/rpc/webapi/client.dart';

class _FocusID {
  _FocusID._();
  static const arrowBack = MyFocusNode.arrowBack;
  static const add = 'add';
  static const refresh = 'refresh';
  static const account = 'self_account_';
}

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({
    Key? key,
  }) : super(key: key);
  @override
  _MyAccountPageState createState() => _MyAccountPageState();
}

abstract class _State extends MyState<MyAccountPage> {
  final _source = <Account>[];
  dynamic _error;
  int _account = -1;
  String accountId(int id) => '${_FocusID.account}$id';
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
      account: account.id,
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
      builder: (context) => MyConfirmationDialog(
        title: Text(S.of(context).account.delete),
        child: Text('${_getName(account.name)} of ${account.url}'),
      ),
    ).then((ok) {
      if (isNotClosed && (ok ?? false)) {
        _delete(account);
      }
    });
  }
}

class _MyAccountPageState extends _State with _KeyboardComponent {
  @override
  void initState() {
    super.initState();
    listenKeyUp(onKeyUp);
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backOfAppBar(context),
        title: Text(S.of(context).account.manage),
      ),
      body: _error == null ? _buildBody(context) : buildError(context, _error),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildBody(BuildContext context) {
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
                accountId(node.id),
                data: node,
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
      return FocusScope(
        node: focusScopeNode,
        child: FloatingActionButton(
          focusColor: Theme.of(context).focusColor.withOpacity(0.5),
          focusNode: createFocusNode(_FocusID.refresh),
          tooltip: S.of(context).app.refresh,
          child: const Icon(Icons.refresh),
          onPressed: disabled ? null : _init,
        ),
      );
    }
    return FocusScope(
      node: focusScopeNode,
      child: FloatingActionButton(
        focusColor: Theme.of(context).focusColor.withOpacity(0.5),
        focusNode: createFocusNode(_FocusID.add),
        tooltip: S.of(context).account.add,
        child: const Icon(Icons.add),
        onPressed: disabled ? null : _openNew,
      ),
    );
  }
}

mixin _KeyboardComponent on _State {
  void onKeyUp(KeyEvent evt) {
    if (evt.logicalKey == LogicalKeyboardKey.select) {
      if (enabled) {
        final focused = focusedNode();
        if (focused != null) {
          _selectFocused(focused);
        }
      }
    } else if (evt.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (enabled) {
        final focused = focusedNode();
        if (focused != null) {
          _deleteFocused(focused);
        }
      }
    } else if (evt.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (enabled) {
        final focused = focusedNode();

        if (focused != null) {
          _editFocused(focused);
        }
      }
    }
  }

  void _selectFocused(MyFocusNode focused) {
    switch (focused.id) {
      case _FocusID.arrowBack:
        Navigator.of(context).pop();
        break;
      case _FocusID.add:
        _openNew();
        break;
      case _FocusID.refresh:
        _init();
        break;
      default:
        if (focused.id.startsWith(_FocusID.account)) {
          _openHome(focused.data);
        }
        break;
    }
  }

  void _deleteFocused(MyFocusNode focused) {
    if (focused.id.startsWith(_FocusID.account)) {
      _openDelete(focused.data);
    }
  }

  void _editFocused(MyFocusNode focused) {
    if (focused.id.startsWith(_FocusID.account)) {
      _openEdit(focused.data);
    }
  }
}
