import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piwigo/db/language.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/widget/spin.dart';
import 'package:piwigo/pages/widget/state.dart';

class MySettingsLanguagePage extends StatefulWidget {
  const MySettingsLanguagePage({
    Key? key,
  }) : super(key: key);
  @override
  _MySettingsLanguagePageState createState() => _MySettingsLanguagePageState();
}

abstract class _State extends MyState<MySettingsLanguagePage> {
  String? _language;

  _selected(Language? language) async {
    if (disabled || _language == language?.name) {
      return;
    }
    setState(() {
      disabled = true;
    });
    try {
      if (language == null) {
        await MyLanguage().clear();
      } else {
        await MyLanguage().save(language.name);
      }
      aliveSetState(() {
        disabled = false;
      });
    } catch (e) {
      aliveSetState(() {
        disabled = false;
        BotToast.showText(text: '$e');
      });
    }
  }
}

class _MySettingsLanguagePageState extends _State with _KeyboardComponent {
  @override
  void initState() {
    super.initState();
    listenKeyUp(onKeyUp);
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
      child: _build(context),
    );
  }

  Widget _build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backOfAppBar(context, disabled: disabled),
        title: Text(S.of(context).settingsLanguage.title),
      ),
      body: ListView.builder(
        itemCount: supportedLanguage.length + 1,
        itemBuilder: (context, i) {
          final child = _buildListTile(
            context,
            i.toString(),
            i == 0 ? null : supportedLanguage[i - 1],
          );
          return FocusScope(
            node: focusScopeNode,
            child: child,
          );
        },
      ),
      floatingActionButton: disabled ? createSpinFloating() : null,
    );
  }

  Widget _buildListTile(BuildContext context, String id, Language? language) {
    return ListTile(
      focusNode: createFocusNode(id, data: language),
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
      onTap: disabled
          ? null
          : () {
              _selected(language);
            },
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
      case MyFocusNode.arrowBack:
        Navigator.of(context).pop();
        break;
      default:
        _selected(focused.data);
        break;
    }
  }
}
