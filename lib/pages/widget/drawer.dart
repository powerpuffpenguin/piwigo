import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:piwigo/environment.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/dev/dev.dart';
import 'package:piwigo/routes.dart';
import 'package:piwigo/rpc/webapi/client.dart';
import 'package:url_launcher/url_launcher.dart';

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

class _MyDrawerViewState extends State<MyDrawerView> {
  final tapGestureRecognizer0 = TapGestureRecognizer();
  final tapGestureRecognizer1 = TapGestureRecognizer();
  Client get client => widget.client;
  @override
  void dispose() {
    tapGestureRecognizer0.dispose();
    tapGestureRecognizer1.dispose();
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
            recognizer: tapGestureRecognizer1
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

  _showAbout() {
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
        ListTile(
          leading: const Icon(Icons.arrow_back),
          title: Text(MaterialLocalizations.of(context).backButtonTooltip),
          onTap: widget.disabled
              ? null
              : () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
        ),
      );
      children.add(const Divider());
    }

    children.addAll(<Widget>[
      ListTile(
        leading: const Icon(Icons.settings),
        title: Text(S.of(context).settings.title),
        onTap: () => Navigator.of(context)
          ..pushNamed(
            MyRoutes.settings,
          ),
      ),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.account_box),
        title: Text(S.of(context).account.manage),
        onTap: () => Navigator.of(context)
          ..pushNamed(
            MyRoutes.account,
          ),
      ),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.help),
        title: Text(S.of(context).app.help),
        onTap: () async {
          try {
            const url = 'https://github.com/powerpuffpenguin/piwigo/issues';
            debugPrint('launch $url');
            await launch(url);
          } catch (e) {
            BotToast.showText(text: '$e');
          }
        },
      ),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.info),
        title: Text(
          MaterialLocalizations.of(context)
              .aboutListTileTitle(S.of(context).appName),
        ),
        onTap: _showAbout,
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
