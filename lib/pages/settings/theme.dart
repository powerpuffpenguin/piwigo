import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:piwigo/db/theme.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/widget/spin.dart';
import 'package:ppg_ui/ppg_ui.dart';

class MySettingsThemePage extends StatefulWidget {
  const MySettingsThemePage({
    Key? key,
  }) : super(key: key);
  @override
  _MySettingsThemePageState createState() => _MySettingsThemePageState();
}

class _MySettingsThemePageState extends UIState<MySettingsThemePage> {
  String? _theme;
  @override
  void initState() {
    super.initState();
    addSubscription(MyTheme().subject.listen((v) {
      if (_theme != v) {
        setState(() {
          _theme = v;
        });
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(enabled),
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).settings.theme),
        ),
        body: Builder(
          builder: (context) => ListView(
            children: MyTheme.supported
                .map<Widget>((v) => _buildListTile(context, v))
                .toList()
              ..insert(0, _buildListTile(context, null)),
          ),
        ),
        floatingActionButton: disabled ? createSpinFloating() : null,
      ),
    );
  }

  Widget _buildListTile(BuildContext context, String? theme) {
    return ListTile(
      leading: _theme == theme
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).indicatorColor,
            )
          : const Icon(Icons.style),
      title: Text(
        theme ?? S.of(context).settings.systemDefault,
      ),
      onTap: disabled || _theme == theme
          ? null
          : () async {
              setState(() {
                disabled = true;
              });
              try {
                if (theme == null) {
                  await MyTheme().clear();
                } else {
                  await MyTheme().saveTheme(theme);
                }
              } catch (e) {
                BotToast.showText(text: '$e');
              } finally {
                setState(() {
                  disabled = false;
                });
              }
            },
    );
  }
}
