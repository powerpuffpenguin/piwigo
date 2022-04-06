import 'package:flutter/material.dart';
import 'package:piwigo/db/language.dart';
import 'package:piwigo/db/theme.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/widget/listener/keyboard_listener.dart';
import 'package:piwigo/pages/widget/state.dart';
import 'package:piwigo/routes.dart';

class MySettingsPage extends StatefulWidget {
  const MySettingsPage({
    Key? key,
  }) : super(key: key);
  @override
  _MySettingsPageState createState() => _MySettingsPageState();
}

class _MySettingsPageState extends MyState<MySettingsPage> {
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

  void _openLanguage() {
    Navigator.of(context).pushNamed(MyRoutes.settingsLanguage);
  }

  void _openTheme() {
    Navigator.of(context).pushNamed(MyRoutes.settingsTheme);
  }

  @override
  Widget build(BuildContext context) {
    return MyKeyboardListener(
      focusNode: createFocusNode('MyKeyboardListener'),
      child: _build(context),
      onSelected: disabled
          ? null
          : () {
              final id = focusedNode()?.id ?? '';
              switch (id) {
                case 'arrow_back':
                  Navigator.of(context).pop();
                  break;
                case 'language':
                  _openLanguage();
                  break;
                case 'theme':
                  _openTheme();
                  break;
              }
            },
    );
  }

  Widget _build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backOfAppBar(context),
        title: Text(S.of(context).settings.title),
      ),
      body: ListView(
        children: <Widget>[
          FocusScope(
            autofocus: true,
            node: focusScopeNode,
            child: ListTile(
              focusNode: createFocusNode('language'),
              leading: const Icon(Icons.language),
              title: Text(S.of(context).settings.language),
              subtitle: _language == null
                  ? Text(S.of(context).settings.systemDefault)
                  : Text(_language!.name),
              trailing: _language == null ? null : Text(_language!.description),
              onTap: _openLanguage,
            ),
          ),
          FocusScope(
            node: focusScopeNode,
            child: ListTile(
              focusNode: createFocusNode('theme'),
              leading: const Icon(Icons.style),
              title: Text(S.of(context).settings.theme),
              subtitle: _theme == null
                  ? Text(S.of(context).settings.systemDefault)
                  : Text(_theme!),
              onTap: _openTheme,
            ),
          ),
        ],
      ),
    );
  }
}
