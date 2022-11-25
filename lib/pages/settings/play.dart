import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piwigo/db/play.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/widget/spin.dart';
import 'package:piwigo/pages/widget/state.dart';

class _FocusID {
  _FocusID._();
  static const arrowBack = MyFocusNode.arrowBack;
  static const opened = 'opened';
  static const seconds = 'seconds';
  static const submit = 'submit';
}

class MySettingsPlayPage extends StatefulWidget {
  const MySettingsPlayPage({
    Key? key,
  }) : super(key: key);
  @override
  _MySettingsPlayPageState createState() => _MySettingsPlayPageState();
}

abstract class _State extends MyState<MySettingsPlayPage> {
  bool _opened = false;

  final _secondsController = TextEditingController();
  String _seconds = '';

  final _form = GlobalKey<FormState>();
  _toglleOpened() => setState(() => _opened = !_opened);
  bool get isNotChanged {
    final data = MyPlay.instance.data;
    return _opened == data.opend && _seconds == data.seconds.toString();
  }

  _save() async {
    final form = _form.currentState;
    if (!(form?.validate() ?? false)) {
      return;
    }
    form!.save();
    if (isNotChanged) {
      BotToast.showText(text: 'not changed');
      return;
    }

    setState(() {
      disabled = true;
    });
    try {
      await MyPlay.instance.setData(
        Play(
          opend: _opened,
          seconds: int.parse(_seconds),
        ),
      );
      aliveSetState(() {
        disabled = false;
        BotToast.showText(text: S.of(context).app.sucess);
      });
    } catch (e) {
      aliveSetState(() {
        disabled = false;
        BotToast.showText(text: '$e');
      });
    }
  }
}

class _MySettingsPlayPageState extends _State with _KeyboardComponent {
  @override
  initState() {
    super.initState();
    listenKeyUp(onKeyUp);
    final data = MyPlay.instance.data;
    _opened = data.opend;
    _seconds = data.seconds.toString();
    _secondsController.text = _seconds;
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
        title: Text(S.of(context).settingsVideo.title),
      ),
      body: Form(
        key: _form,
        child: ListView(
          children: [
            FocusScope(
              node: focusScopeNode,
              child: SwitchListTile(
                focusNode: createFocusNode(_FocusID.opened),
                title: Text(S.of(context).settingsPlay.autoplay),
                value: _opened,
                onChanged: disabled
                    ? null
                    : (val) {
                        if (_opened != val) {
                          aliveSetState(() {
                            _opened = val;
                          });
                        }
                      },
              ),
            ),
            FocusScope(
              node: focusScopeNode,
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                enabled: enabled,
                focusNode: createFocusNode(_FocusID.seconds),
                controller: _secondsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.scale),
                  label: Text(S.of(context).settingsPlay.waitSeconds),
                ),
                onSaved: (val) {
                  _seconds = val ?? '';
                },
                validator: (str) {
                  try {
                    int v = int.parse(str ?? '');
                    if (v < 1 || v > 60) {
                      return "scale must range at [1,60]";
                    }
                  } catch (e) {
                    return '$e';
                  }
                  return null;
                },
                onEditingComplete: () {
                  setFocus(_FocusID.submit);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    if (disabled) {
      return createSpinFloating();
    }
    return FocusScope(
      node: focusScopeNode,
      child: FloatingActionButton(
        focusColor: Theme.of(context).focusColor.withOpacity(0.5),
        focusNode: createFocusNode(_FocusID.submit),
        child: const Icon(Icons.save),
        tooltip: S.of(context).app.save,
        onPressed: disabled ? null : _save,
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
    } else if (evt.logicalKey == LogicalKeyboardKey.arrowUp) {
      final focused = focusedNode();
      if (focused != null) {
        switch (focused.id) {
          case _FocusID.arrowBack:
            setFocus(_FocusID.submit, focused: focused.focusNode);
            break;
        }
      }
    } else if (evt.logicalKey == LogicalKeyboardKey.arrowRight) {
      final focused = focusedNode();
      if (focused != null) {
        switch (focused.id) {
          case _FocusID.submit:
            setFocus(_FocusID.arrowBack, focused: focused.focusNode);
            break;
        }
      }
    }
  }

  _nextFocus(MyFocusNode focused) {
    switch (focused.id) {
      case _FocusID.opened:
        setFocus(_FocusID.seconds, focused: focused.focusNode);
        break;
      case _FocusID.seconds:
        setFocus(_FocusID.submit, focused: focused.focusNode);
        break;
    }
  }

  _selectFocused(MyFocusNode focused) {
    switch (focused.id) {
      case _FocusID.arrowBack:
        Navigator.of(context).pop();
        break;
      case _FocusID.opened:
        _toglleOpened();
        break;
      case _FocusID.seconds:
        _nextFocus(focused);
        break;
      case _FocusID.submit:
        _save();
        break;
    }
  }
}
