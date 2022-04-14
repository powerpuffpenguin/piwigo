import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piwigo/db/video.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/widget/spin.dart';
import 'package:piwigo/pages/widget/state.dart';

class _FocusID {
  _FocusID._();
  static const arrowBack = MyFocusNode.arrowBack;
  static const reverse = 'reverse';
  static const scale = 'scale';
  static const rotate = 'rotate';
  static const reverse1 = 'reverse1';
  static const scale1 = 'scale1';
  static const rotate1 = 'rotate1';
  static const submit = 'submit';
}

class MySettingsVideoPage extends StatefulWidget {
  const MySettingsVideoPage({
    Key? key,
  }) : super(key: key);
  @override
  _MySettingsVideoPageState createState() => _MySettingsVideoPageState();
}

abstract class _State extends MyState<MySettingsVideoPage> {
  bool _reverse = false;
  bool _reverse1 = false;

  final _scaleController = TextEditingController();
  final _rotateController = TextEditingController();
  String _scale = '';
  String _rotate = '';

  final _scaleController1 = TextEditingController();
  final _rotateController1 = TextEditingController();
  String _scale1 = '';
  String _rotate1 = '';
  final _form = GlobalKey<FormState>();
  _toglleReverse() => setState(() => _reverse = !_reverse);
  _toglleReverse1() => setState(() => _reverse1 = !_reverse1);
  bool get isNotChanged {
    final data = MyVideo.instance.data;
    return _scale == data.scale.toString() &&
        _rotate == data.rotate.toString() &&
        _reverse == data.reverse &&
        _scale1 == data.scale1.toString() &&
        _rotate1 == data.rotate1.toString() &&
        _reverse1 == data.reverse1;
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
      await MyVideo.instance.setData(
        Video(
          reverse: _reverse,
          scale: int.parse(_scaleController.text),
          rotate: int.parse(_rotateController.text),
          reverse1: _reverse1,
          scale1: int.parse(_scaleController1.text),
          rotate1: int.parse(_rotateController1.text),
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

class _MySettingsVideoPageState extends _State with _KeyboardComponent {
  @override
  initState() {
    super.initState();
    listenKeyUp(onKeyUp);
    final data = MyVideo.instance.data;
    _scale = data.scale.toString();
    _rotate = data.rotate.toString();
    _scaleController.text = _scale;
    _rotateController.text = _rotate;
    _reverse = data.reverse;

    _scale1 = data.scale1.toString();
    _rotate1 = data.rotate1.toString();
    _scaleController1.text = _scale1;
    _rotateController1.text = _rotate1;
    _reverse1 = data.reverse1;
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
            const Text("<1"),
            FocusScope(
              node: focusScopeNode,
              child: SwitchListTile(
                focusNode: createFocusNode(_FocusID.reverse),
                title: Text(S.of(context).settingsVideo.reverse),
                value: _reverse,
                onChanged: disabled
                    ? null
                    : (val) {
                        if (_reverse != val) {
                          aliveSetState(() {
                            _reverse = val;
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
                focusNode: createFocusNode(_FocusID.scale),
                controller: _scaleController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.scale),
                  label: Text(S.of(context).settingsVideo.scale),
                ),
                onSaved: (val) {
                  _scale = val ?? '';
                },
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
                  setFocus(_FocusID.rotate);
                },
              ),
            ),
            FocusScope(
              node: focusScopeNode,
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                enabled: enabled,
                focusNode: createFocusNode(_FocusID.rotate),
                controller: _rotateController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.rotate_90_degrees_cw),
                  label: Text(S.of(context).settingsVideo.rotate),
                ),
                onSaved: (val) {
                  _rotate = val ?? '';
                },
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
                  setFocus(_FocusID.reverse1);
                },
              ),
            ),
            const Text(">1"),
            FocusScope(
              node: focusScopeNode,
              child: SwitchListTile(
                focusNode: createFocusNode(_FocusID.reverse1),
                title: Text(S.of(context).settingsVideo.reverse),
                value: _reverse1,
                onChanged: disabled
                    ? null
                    : (val) {
                        if (_reverse1 != val) {
                          aliveSetState(() {
                            _reverse1 = val;
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
                focusNode: createFocusNode(_FocusID.scale1),
                controller: _scaleController1,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.scale),
                  label: Text(S.of(context).settingsVideo.scale),
                ),
                onSaved: (val) {
                  _scale1 = val ?? '';
                },
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
                  setFocus(_FocusID.rotate1);
                },
              ),
            ),
            FocusScope(
              node: focusScopeNode,
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                enabled: enabled,
                focusNode: createFocusNode(_FocusID.rotate1),
                controller: _rotateController1,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.rotate_90_degrees_cw),
                  label: Text(S.of(context).settingsVideo.rotate),
                ),
                onSaved: (val) {
                  _rotate1 = val ?? '';
                },
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
      case _FocusID.scale:
        setFocus(_FocusID.rotate, focused: focused.focusNode);
        break;
      case _FocusID.rotate:
        setFocus(_FocusID.reverse1, focused: focused.focusNode);
        break;
      case _FocusID.scale1:
        setFocus(_FocusID.rotate1, focused: focused.focusNode);
        break;
      case _FocusID.rotate1:
        setFocus(_FocusID.submit, focused: focused.focusNode);
        break;
    }
  }

  _selectFocused(MyFocusNode focused) {
    switch (focused.id) {
      case _FocusID.arrowBack:
        Navigator.of(context).pop();
        break;
      case _FocusID.reverse:
        _toglleReverse();
        break;
      case _FocusID.reverse1:
        _toglleReverse1();
        break;
      case _FocusID.rotate:
      case _FocusID.scale:
      case _FocusID.rotate1:
      case _FocusID.scale1:
        _nextFocus(focused);
        break;
      case _FocusID.submit:
        _save();
        break;
    }
  }
}
