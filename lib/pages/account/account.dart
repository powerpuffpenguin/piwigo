import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:piwigo/db/data/account.dart';
import 'package:piwigo/db/db.dart';
import 'package:piwigo/db/settings.dart';
import 'package:piwigo/environment.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/home/home.dart';
import 'package:piwigo/pages/load/add.dart';
import 'package:piwigo/pages/widget/spin.dart';
import 'package:piwigo/rpc/webapi/client.dart';
import 'package:ppg_ui/ppg_ui.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({
    Key? key,
  }) : super(key: key);
  @override
  _MyAccountPageState createState() => _MyAccountPageState();
}

class _MyAccountPageState extends UIState<MyAccountPage> {
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

  _go(Account account) {
    final client = Client(
        baseUrl: account.url, name: account.name, password: account.password);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MyHomePage(
          client: client,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).account.manage),
      ),
      body: _error == null ? _buildBody(context) : buildError(context, _error),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget? _buildBody(BuildContext context) {
    return ListView(
      children: _source.map<Widget>(
        (node) {
          final name = node.name.isEmpty ? 'guest' : node.name;
          var title = MyEnvironment.isDebug ? '$name ${node.id}' : name;
          return ListTile(
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
              onPressed: disabled
                  ? null
                  : () {
                      showConfirmationDialog(
                        context,
                        title: Text(S.of(context).account.delete),
                        child: Text('$name of ${node.url}'),
                      ).then((ok) {
                        if (isNotClosed && (ok ?? false)) {
                          _delete(node);
                        }
                      });
                    },
            ),
            onTap: disabled ? null : () => _go(node),
            onLongPress: disabled
                ? null
                : () {
                    Navigator.of(context)
                        .push<Account>(
                      MaterialPageRoute(
                        builder: (_) => MyAddPage(
                          account: node,
                        ),
                      ),
                    )
                        .then((account) {
                      if (account != null && isNotClosed) {
                        setState(() {
                          node.name = account.name;
                          node.url = account.url;
                        });
                      }
                    });
                  },
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
    return FloatingActionButton(
      tooltip: S.of(context).account.add,
      child: const Icon(Icons.add),
      onPressed: disabled
          ? null
          : () {
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
            },
    );
  }
}
