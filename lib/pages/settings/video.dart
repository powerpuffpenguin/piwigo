import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piwigo/db/video.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/widget/listener/keyboard_listener.dart';
import 'package:piwigo/pages/widget/state.dart';

class MySettingsVideoPage extends StatefulWidget {
  const MySettingsVideoPage({
    Key? key,
  }) : super(key: key);
  @override
  _MySettingsVideoPageState createState() => _MySettingsVideoPageState();
}

class _MySettingsVideoPageState extends MyState<MySettingsVideoPage> {
  bool _reverse = false;

  final _scaleController = TextEditingController();
  final _rotateController = TextEditingController();
  final _form = GlobalKey<FormState>();

  @mustCallSuper
  @override
  initState() {
    super.initState();
    final data = MyVideo.instance.data;
    _scaleController.text = data.scale.toString();
    _rotateController.text = data.rotate.toString();
    _reverse = data.reverse;
  }

  _onSelect(MyFocusNode focused, KeyEvent evt) {
    if (focused.isArrowBack) {
      Navigator.of(context).pop();
    } else if (focused.id == 'scale') {
      if (evt.logicalKey == LogicalKeyboardKey.select) {
        setFocus('rotate');
      }
    } else if (focused.id == 'rotate') {
      if (evt.logicalKey == LogicalKeyboardKey.select) {
        setFocus('save');
      }
    } else if (focused.id == 'save') {
      if (evt.logicalKey == LogicalKeyboardKey.select) {
        _save();
      }
    } else if (focused.id == 'reverse') {
      if (evt.logicalKey == LogicalKeyboardKey.select) {
        setState(() {
          _reverse = !_reverse;
        });
      }
    }
  }

  _save() async {
    final form = _form.currentState;
    if (!(form?.validate() ?? false)) {
      return;
    }

    setState(() {
      disabled = true;
    });
    try {
      await MyVideo.instance.setData(
        Video(
          reverse: _reverse,
          scale: int.parse(_scaleController.text),
          rotate: int.parse(_rotateController.text),
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(enabled),
      child: MyKeyboardListener(
        focusNode: createFocusNode('MyKeyboardListener'),
        child: _build(context),
        onKeyTab: disabled
            ? null
            : (evt) {
                if (evt.logicalKey == LogicalKeyboardKey.select ||
                    evt.logicalKey == LogicalKeyboardKey.enter) {
                  final focused = focusedNode();
                  if (focused == null) {
                    return;
                  }
                  _onSelect(focused, evt);
                }
              },
      ),
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
                focusNode: createFocusNode('reverse'),
                title: Text(S.of(context).settingsVideo.reverse),
                value: _reverse,
                onChanged: disabled
                    ? null
                    : (val) {
                        setState(() {
                          _reverse = val;
                        });
                      },
              ),
            ),
            FocusScope(
              node: focusScopeNode,
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                enabled: enabled,
                focusNode: createFocusNode('scale'),
                controller: _scaleController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.scale),
                  label: Text(S.of(context).settingsVideo.scale),
                ),
                validator: (str) {
                  try {
                    int v = int.parse(str ?? '');
                    if (v < -50 || v > 50) {
                      return "scale must range at [-50,50]";
                    }
                  } catch (e) {
                    return '$e';
                  }
                  return null;
                },
                onEditingComplete: () {
                  setFocus('rotate');
                },
              ),
            ),
            FocusScope(
              node: focusScopeNode,
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                enabled: enabled,
                focusNode: createFocusNode('rotate'),
                controller: _rotateController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.rotate_90_degrees_cw),
                  label: Text(S.of(context).settingsVideo.rotate),
                ),
                validator: (str) {
                  try {
                    int v = int.parse(str ?? '');
                    if (v < 0 || v > 3) {
                      return "rotate must range at [0,3]";
                    }
                  } catch (e) {
                    return '$e';
                  }
                  return null;
                },
                onEditingComplete: () {
                  setFocus('save');
                },
              ),
            ),
            FocusScope(
              node: focusScopeNode,
              child: TextButton(
                focusNode: createFocusNode('save'),
                child: Text(S.of(context).app.save),
                onPressed: disabled ? null : _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
