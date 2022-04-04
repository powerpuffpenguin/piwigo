import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:king011_icons/king011_icons.dart';
import 'package:piwigo/db/data/account.dart';
import 'package:piwigo/db/db.dart';
import 'package:piwigo/db/settings.dart';
import 'package:piwigo/environment.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/home/home.dart';
import 'package:piwigo/pages/widget/spin.dart';
import 'package:piwigo/rpc/webapi/client.dart';
import 'package:ppg_ui/ppg_ui.dart';

class MyAddPage extends StatefulWidget {
  const MyAddPage({
    Key? key,
    this.account,
    this.push = false,
  }) : super(key: key);
  final Account? account;
  final bool push;
  @override
  _MyAddPageState createState() => _MyAddPageState();
}

class _MyAddPageState extends UIState<MyAddPage> {
  final _urlController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlFocus = FocusNode();
  final _nameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _form = GlobalKey();
  var _visibility = false;
  dynamic _error;
  final _cancelToken = CancelToken();
  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _urlController.text = widget.account!.url;
      _nameController.text = widget.account!.name;
      _passwordController.text = widget.account!.password;
    }
    if (_urlController.text == '') {
      _urlFocus.requestFocus();
    }
  }

  @override
  void dispose() {
    _urlFocus.dispose();
    _nameFocus.dispose();
    _passwordFocus.dispose();
    _cancelToken.cancel();
    super.dispose();
  }

  _submit() async {
    final url = _urlController.text;
    final name = _nameController.text;
    final password = _passwordController.text;

    if (widget.account != null) {
      final account = widget.account!;
      if (account.url == url &&
          account.name == name &&
          account.password == password) {
        Navigator.of(context).pop();
        return;
      }
    }
    setState(() {
      disabled = true;
      _error = null;
    });
    try {
      // verify
      final client = Client(
        baseUrl: url,
        name: name,
        password: password,
      );
      if (name.isNotEmpty) {
        await client.login(cancelToken: _cancelToken);
        checkAlive();
      }
      final status = await client.getStatus(cancelToken: _cancelToken);
      checkAlive();
      client.status = status;
      // save db
      final helper = (await DB.helpers).account;
      checkAlive();
      final account = Account(id: 0, url: url, name: name, password: password);
      if (widget.account == null) {
        // add
        final id = await helper.add(account);
        debugPrint('insert id: $id');
        checkAlive();
        account.id = id;
      } else {
        // edit
        account.id = widget.account!.id;
        await helper.updateById(
          account.id,
          account.toMap()..remove(AccountHelper.columnID),
        );
        checkAlive();
      }
      if (widget.push) {
        MySettings.instance.setAccount(account.id);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MyHomePage(
              client: client,
            ),
          ),
        );
      } else {
        Navigator.of(context).pop(account);
      }
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
      appBar: AppBar(
        title: Text(widget.account == null
            ? S.of(context).account.add
            : S.of(context).account.edit),
      ),
      body: Form(
        key: _form,
        child: ListView(
          children: [
            TextFormField(
              enabled: enabled,
              controller: _urlController,
              focusNode: _urlFocus,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                prefixIcon: const Icon(MaterialCommunityIcons.server),
                label: Text(S.of(context).account.url),
              ),
              onEditingComplete: () => _nameFocus.requestFocus(),
            ),
            TextFormField(
              enabled: enabled,
              controller: _nameController,
              focusNode: _nameFocus,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.account_circle),
                label: Text(S.of(context).account.name),
              ),
              onEditingComplete: () => _passwordFocus.requestFocus(),
            ),
            TextFormField(
              enabled: enabled,
              controller: _passwordController,
              focusNode: _passwordFocus,
              keyboardType: TextInputType.visiblePassword,
              obscureText: !_visibility,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.password),
                label: Text(S.of(context).account.password),
                suffix: IconButton(
                    onPressed: () =>
                        aliveSetState(() => _visibility = !_visibility),
                    icon: _visibility
                        ? const Icon(Icons.visibility)
                        : const Icon(Icons.visibility_off)),
              ),
              onEditingComplete: _submit,
            ),
            _error == null
                ? Container()
                : Container(
                    padding: const EdgeInsets.all(MyEnvironment.viewPadding),
                    child: Text(
                      '$_error',
                      style: TextStyle(color: Theme.of(context).errorColor),
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    if (disabled) {
      return createSpinFloating();
    }
    return FloatingActionButton(
      child: const Icon(Icons.send),
      tooltip: S.of(context).app.submit,
      onPressed: disabled ? null : _submit,
    );
  }
}
