import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:piwigo/db/language.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/widget/spin.dart';
import 'package:ppg_ui/ppg_ui.dart';

class MySettingsLanguagePage extends StatefulWidget {
  const MySettingsLanguagePage({
    Key? key,
  }) : super(key: key);
  @override
  _MySettingsLanguagePageState createState() => _MySettingsLanguagePageState();
}

class _MySettingsLanguagePageState extends UIState<MySettingsLanguagePage> {
  String? _language;
  @override
  void initState() {
    super.initState();
    addSubscription(MyLanguage().subject.listen((v) {
      if (_language != v) {
        setState(() {
          _language = v;
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
          title: Text(S.of(context).settingsLanguage.title),
        ),
        body: Builder(
          builder: (context) => ListView(
            children: supportedLanguage
                .map<Widget>((v) => _buildListTile(context, v))
                .toList()
              ..insert(0, _buildListTile(context, null)),
          ),
        ),
        floatingActionButton: disabled ? createSpinFloating() : null,
      ),
    );
  }

  Widget _buildListTile(BuildContext context, Language? language) {
    return ListTile(
      leading: _language == language?.name
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).indicatorColor,
            )
          : const Icon(Icons.language),
      title: Text(
        language == null ? S.of(context).settings.systemDefault : language.name,
      ),
      trailing: language == null ? null : Text(language.description),
      onTap: disabled || _language == language?.name
          ? null
          : () async {
              setState(() {
                disabled = true;
              });
              try {
                if (language == null) {
                  await MyLanguage().clear();
                } else {
                  await MyLanguage().save(language.name);
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
