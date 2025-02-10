import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piwigo/db/language.dart';
import 'package:piwigo/db/theme.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/widget/state.dart';
import 'package:piwigo/routes.dart';

class _FocusID {
  _FocusID._();
  static const arrowBack = MyFocusNode.arrowBack;
  static const language = 'language';
  static const theme = 'theme';
  static const video = 'video';
  static const play = 'play';
  static const quality = 'quality';
}

class MySettingsPage extends StatefulWidget {
  const MySettingsPage({
    Key? key,
  }) : super(key: key);
  @override
  _MySettingsPageState createState() => _MySettingsPageState();
}

abstract class _State extends MyState<MySettingsPage> {
  Language? _language;
  String? _theme;
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

  void _openQuality() {
    Navigator.of(context).pushNamed(MyRoutes.settingsQuality);
  }

  void _openVideo() {
    Navigator.of(context).pushNamed(MyRoutes.settingsVideo);
  }

  void _openPlay() {
    Navigator.of(context).pushNamed(MyRoutes.settingsPlay);
  }
}

class _MySettingsPageState extends _State with _KeyboardComponent {
  @override
  void initState() {
    super.initState();
    listenKeyUp(onKeyUp);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backOfAppBar(context),
        title: Text(S.of(context).settings.title),
      ),
      body: ListView(
        children: <Widget>[
          FocusScope(
            node: focusScopeNode,
            child: ListTile(
              focusNode: createFocusNode(_FocusID.language),
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
              focusNode: createFocusNode(_FocusID.theme),
              leading: const Icon(Icons.style),
              title: Text(S.of(context).settings.theme),
              subtitle: _theme == null
                  ? Text(S.of(context).settings.systemDefault)
                  : Text(_theme!),
              onTap: _openTheme,
            ),
          ),
          FocusScope(
            node: focusScopeNode,
            child: ListTile(
              focusNode: createFocusNode(_FocusID.quality),
              leading: const Icon(Icons.image),
              title: Text(S.of(context).settingsQuality.title),
              onTap: _openQuality,
            ),
          ),
          FocusScope(
            node: focusScopeNode,
            child: ListTile(
              focusNode: createFocusNode(_FocusID.video),
              leading: const Icon(Icons.video_settings),
              title: Text(S.of(context).settingsVideo.title),
              onTap: _openVideo,
            ),
          ),
          FocusScope(
            node: focusScopeNode,
            child: ListTile(
              focusNode: createFocusNode(_FocusID.play),
              leading: const Icon(Icons.play_circle_fill),
              title: Text(S.of(context).settingsPlay.title),
              onTap: _openPlay,
            ),
          ),
        ],
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

  void _selectFocused(MyFocusNode focused) {
    switch (focused.id) {
      case _FocusID.arrowBack:
        Navigator.of(context).pop();
        break;
      case _FocusID.language:
        _openLanguage();
        break;
      case _FocusID.theme:
        _openTheme();
        break;
      case _FocusID.quality:
        _openQuality();
        break;
      case _FocusID.video:
        _openVideo();
        break;
      case _FocusID.play:
        _openPlay();
        break;
    }
  }
}
