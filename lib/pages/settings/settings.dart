import 'package:flutter/material.dart';
import 'package:piwigo/db/language.dart';
import 'package:piwigo/db/theme.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/routes.dart';
import 'package:ppg_ui/ppg_ui.dart';

class MySettingsPage extends StatefulWidget {
  const MySettingsPage({
    Key? key,
  }) : super(key: key);
  @override
  _MySettingsPageState createState() => _MySettingsPageState();
}

class _MySettingsPageState extends UIState<MySettingsPage> {
  Language? _language;
  String? _theme;

  @override
  void initState() {
    super.initState();
    addAllSubscription([
      MyLanguage().subject.listen((v) {
        final current = getLanguage(v);
        if (current == null) {
          if (_language != null) {
            setState(() {
              _language = null;
            });
          }
        } else {
          if (_language != current) {
            setState(() {
              _language = current;
            });
          }
        }
      }),
      MyTheme().subject.listen((v) {
        if (_theme != v) {
          setState(() {
            _theme = v;
          });
        }
      }),
    ]);
  }

  Language? getLanguage(String? name) {
    if (name == null) {
      return null;
    }
    final supported = getSupported();
    return supported[name];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settings.title),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(S.of(context).settings.language),
            subtitle: _language == null
                ? Text(S.of(context).settings.systemDefault)
                : Text(_language!.name),
            trailing: _language == null ? null : Text(_language!.description),
            onTap: () =>
                Navigator.of(context).pushNamed(MyRoutes.settingsLanguage),
          ),
          ListTile(
            leading: const Icon(Icons.style),
            title: Text(S.of(context).settings.theme),
            subtitle: _theme == null
                ? Text(S.of(context).settings.systemDefault)
                : Text(_theme!),
            onTap: () =>
                Navigator.of(context).pushNamed(MyRoutes.settingsTheme),
          ),
        ],
      ),
    );
  }
}
