import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:piwigo/db/theme.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/widget/listener/keyboard_listener.dart';
import 'package:piwigo/pages/widget/spin.dart';
import 'package:piwigo/pages/widget/state.dart';

class MySettingsThemePage extends StatefulWidget {
  const MySettingsThemePage({
    Key? key,
  }) : super(key: key);
  @override
  _MySettingsThemePageState createState() => _MySettingsThemePageState();
}

class _MySettingsThemePageState extends MyState<MySettingsThemePage> {
  late String _theme;
  @override
  void initState() {
    super.initState();
    _theme = MyTheme.instance.value;
    addSubscription(MyTheme().subject.listen((v) {
      if (_theme != v) {
        setState(() {
          _theme = v;
        });
      }
    }));
  }

  _selected(String? theme) async {
    if (disabled || _theme == theme) {
      return;
    }
    setState(() {
      disabled = true;
    });
    try {
      if (theme == null) {
        await MyTheme().save('');
      } else {
        await MyTheme().save(theme);
      }
      aliveSetState(() {
        disabled = false;
      });
    } catch (e) {
      if (isNotClosed) {
        BotToast.showText(text: '$e');
        disabled = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(enabled),
      child: MyKeyboardListener(
        focusNode: createFocusNode('MyKeyboardListener'),
        child: _build(context),
        onKeySubmit: disabled
            ? null
            : (evt) {
                final focused = focusedNode();
                if (focused == null) {
                  return;
                }
                if (focused.isArrowBack) {
                  Navigator.of(context).pop();
                  return;
                }
                _selected(focused.data);
              },
      ),
    );
  }

  Widget _build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backOfAppBar(context),
        title: Text(S.of(context).settings.theme),
      ),
      body: ListView.builder(
        itemCount: MyTheme.supported.length + 1,
        itemBuilder: (context, i) {
          final child = _buildListTile(
            context,
            i.toString(),
            i == 0 ? null : MyTheme.supported[i - 1].item1,
          );
          return FocusScope(
            autofocus: true,
            node: focusScopeNode,
            child: child,
          );
        },
      ),
      floatingActionButton: disabled ? createSpinFloating() : null,
    );
  }

  Widget _buildListTile(BuildContext context, String id, String? theme) {
    return ListTile(
      focusNode: createFocusNode(id, data: theme),
      leading: _theme == (theme ?? '')
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).indicatorColor,
            )
          : const Icon(Icons.style),
      title: Text(
        theme ?? S.of(context).settings.systemDefault,
      ),
      onTap: disabled
          ? null
          : () {
              _selected(theme);
            },
    );
  }
}
