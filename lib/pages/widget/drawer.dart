import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:piwigo/environment.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/dev/dev.dart';
import 'package:piwigo/pages/widget/listener/keyboard_listener.dart';
import 'package:piwigo/pages/widget/state.dart';
import 'package:piwigo/routes.dart';
import 'package:piwigo/rpc/webapi/client.dart';
import 'package:url_launcher/url_launcher.dart';

class _FocusID {
  _FocusID._();
  static const arrowBack = MyFocusNode.arrowBack;
  static const settings = 'settings';
  static const account = 'account';
  static const help = 'help';
  static const about = 'about';
}

class MyDrawerView extends StatefulWidget {
  const MyDrawerView({
    Key? key,
    this.back = false,
    this.disabled = false,
    required this.client,
  }) : super(key: key);

  /// 是否需要 返回按鈕
  final bool back;

  /// 是否禁用 功能按鈕
  final bool disabled;

  final Client client;
  @override
  _MyDrawerViewState createState() => _MyDrawerViewState();
}

abstract class _State extends MyState<MyDrawerView> {
  final _recognizer = <String, TapGestureRecognizer>{};
  TapGestureRecognizer createRecognizer(String id) {
    var recognizer = _recognizer[id];
    if (recognizer == null) {
      recognizer = TapGestureRecognizer();
      _recognizer[id] = recognizer;
    }
    return recognizer;
  }

  @override
  void dispose() {
    _recognizer.forEach((key, value) {
      value.dispose();
    });
    super.dispose();
  }

  Widget _richTextUrl(String tag, String url, TextStyle? style) {
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(style: style, text: '$tag '),
          TextSpan(
            style: style?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
            text: url,
            recognizer: createRecognizer(url)
              ..onTap = () async {
                try {
                  debugPrint('launch $url');
                  await launch(url);
                } catch (e) {
                  BotToast.showText(text: '$e');
                }
              },
          ),
          TextSpan(style: style, text: ' .'),
        ],
      ),
    );
  }

  void _openAbout() {
    final TextStyle? textStyle = Theme.of(context).textTheme.bodyText1;
    final children = <Widget>[
      _richTextUrl(
        'Source code at',
        'https://github.com/powerpuffpenguin/piwigo',
        textStyle,
      ),
      _richTextUrl(
        'LICENSE at',
        'https://raw.githubusercontent.com/powerpuffpenguin/piwigo/main/LICENSE',
        textStyle,
      ),
    ];
    if (Platform.isAndroid) {
      children.add(
          _richTextUrl('Play Store at', MyEnvironment.playStore, textStyle));
    }
    showAboutDialog(
      context: context,
      applicationName: S.of(context).appName,
      applicationVersion: MyEnvironment.version,
      applicationIcon: SizedBox(
        width: 80,
        height: 80,
        child: Image.asset("assets/piwigo.png"),
      ),
      applicationLegalese: MyEnvironment.applicationLegalese,
      children: children,
    );
  }

  void _openSettings() {
    Navigator.of(context).pushNamed(
      MyRoutes.settings,
    );
  }

  void _openAccount() {
    Navigator.of(context).pushNamed(
      MyRoutes.account,
    );
  }

  void _openHelp() async {
    try {
      const url = 'https://github.com/powerpuffpenguin/piwigo/issues';
      debugPrint('launch $url');
      await launch(url);
    } catch (e) {
      if (isNotClosed) {
        BotToast.showText(text: '$e');
      }
    }
  }

  void _backup() {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }
}

class _MyDrawerViewState extends _State with _KeyboardComponent {
  Client get client => widget.client;
  @override
  void initState() {
    super.initState();
    listenKeyUp(onKeyUp);
  }

  @override
  Widget build(BuildContext context) {
    final status = client.status;
    final children = <Widget>[
      DrawerHeader(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Image.asset(
              "assets/piwigo.org.png",
            ),
            Text(status?.username ?? client.name),
            Text(client.dio.options.baseUrl),
          ],
        ),
      ),
    ];
    if (widget.back) {
      children.add(
        FocusScope(
          node: focusScopeNode,
          child: ListTile(
            focusNode: createFocusNode(_FocusID.arrowBack),
            leading: const Icon(Icons.arrow_back),
            title: Text(MaterialLocalizations.of(context).backButtonTooltip),
            onTap: widget.disabled ? null : _backup,
          ),
        ),
      );
      children.add(const Divider());
    }

    children.addAll(<Widget>[
      FocusScope(
        node: focusScopeNode,
        child: ListTile(
          focusNode: createFocusNode(_FocusID.settings),
          leading: const Icon(Icons.settings),
          title: Text(S.of(context).settings.title),
          onTap: widget.disabled ? null : _openSettings,
        ),
      ),
      const Divider(),
      FocusScope(
        node: focusScopeNode,
        child: ListTile(
          focusNode: createFocusNode(_FocusID.account),
          leading: const Icon(Icons.account_box),
          title: Text(S.of(context).account.manage),
          onTap: widget.disabled ? null : _openAccount,
        ),
      ),
      const Divider(),
      FocusScope(
        autofocus: true,
        node: focusScopeNode,
        child: ListTile(
          focusNode: createFocusNode(_FocusID.help),
          leading: const Icon(Icons.help),
          title: Text(S.of(context).app.help),
          onTap: widget.disabled ? null : _openHelp,
        ),
      ),
      const Divider(),
      FocusScope(
        autofocus: true,
        node: focusScopeNode,
        child: ListTile(
          focusNode: createFocusNode(_FocusID.about),
          leading: const Icon(Icons.info),
          title: Text(
            MaterialLocalizations.of(context)
                .aboutListTileTitle(S.of(context).appName),
          ),
          onTap: widget.disabled ? null : _openAbout,
        ),
      ),
    ]);
    if (MyEnvironment.isDebug) {
      children.addAll(<Widget>[
        const Divider(),
        ListTile(
          leading: const Icon(Icons.adb),
          title: const Text("測試"),
          onTap: widget.disabled
              ? null
              : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MyDevPage(
                        client: widget.client,
                      ),
                    ),
                  );
                },
        ),
      ]);
    }
    return Drawer(
      child: ListView(
        children: children,
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
    }
  }

  _selectFocused(MyFocusNode focused) {
    switch (focused.id) {
      case _FocusID.arrowBack:
        _backup();
        break;
      case _FocusID.settings:
        _openSettings();
        break;
      case _FocusID.account:
        _openAccount();
        break;
      case _FocusID.help:
        _openHelp();
        break;
      case _FocusID.about:
        _openAbout();
        break;
    }
  }
}
