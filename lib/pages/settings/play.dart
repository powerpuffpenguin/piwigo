import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:piwigo/db/play.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/widget/spin.dart';
import 'package:piwigo/tv/focusable.dart';

class MySettingsPlayPage extends StatefulWidget {
  const MySettingsPlayPage({
    Key? key,
  }) : super(key: key);
  @override
  _MySettingsPlayPageState createState() => _MySettingsPlayPageState();
}

class _MySettingsPlayPageState extends State {
  bool _opened = false;
  bool _random = false;
  bool _loop = false;
  final _focusNode = FocusNode();
  final _secondsController = TextEditingController();
  String _seconds = '';

  final _focusNodeBar = FocusNode();

  final _form = GlobalKey<FormState>();
  _toglleOpened() => setState(() => _opened = !_opened);
  _toglleRandom() => setState(() => _random = !_random);
  _toglleLoop() => setState(() => _loop = !_loop);
  bool disabled = false;
  bool closed = false;

  bool get isNotChanged {
    final data = MyPlay.instance.data;
    return _opened == data.opend &&
        _random == data.random &&
        _loop == data.loop &&
        _seconds == data.seconds.toString();
  }

  aliveSetState(void Function() fn) {
    if (!closed) {
      setState(fn);
    }
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
          random: _random,
          loop: _loop,
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

  @override
  initState() {
    super.initState();
    final data = MyPlay.instance.data;
    _opened = data.opend;
    _random = data.random;
    _loop = data.loop;
    _seconds = data.seconds.toString();
    _secondsController.text = _seconds;
  }

  @override
  void dispose() {
    closed = true;
    _focusNode.dispose();
    _focusNodeBar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(!disabled),
      child: _build(context),
    );
  }

  Widget _build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: FocusableWidget(
          focusNode: _focusNodeBar,
          child: BackButton(
            onPressed: () => Navigator.maybePop(context),
          ),
          onMove: (f, k, d) {
            switch (d) {
              case TraversalDirection.up:
                _focusNode.requestFocus();
                return KeyEventResult.handled;
              default:
                break;
            }
            return KeyEventResult.ignored;
          },
        ),
        title: Text(S.of(context).settingsVideo.title),
      ),
      body: Form(
        key: _form,
        child: ListView(
          children: [
            FocusableWidget(
              onOK: (_, __) {
                _toglleOpened();
                return KeyEventResult.handled;
              },
              child: SwitchListTile(
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
            FocusableWidget(
              onOK: (_, __) {
                _toglleRandom();
                return KeyEventResult.handled;
              },
              child: SwitchListTile(
                title: Text(S.of(context).settingsPlay.random),
                value: _random,
                onChanged: disabled
                    ? null
                    : (val) {
                        if (_random != val) {
                          aliveSetState(() {
                            _random = val;
                          });
                        }
                      },
              ),
            ),
            FocusableWidget(
              onOK: (_, __) {
                _toglleLoop();
                return KeyEventResult.handled;
              },
              child: SwitchListTile(
                title: Text(S.of(context).settingsPlay.loop),
                value: _loop,
                onChanged: disabled
                    ? null
                    : (val) {
                        if (_loop != val) {
                          aliveSetState(() {
                            _loop = val;
                          });
                        }
                      },
              ),
            ),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              enabled: !disabled,
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
                _focusNode.requestFocus();
              },
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
    return FocusableWidget(
      child: FloatingActionButton(
        focusNode: _focusNode,
        focusColor: Theme.of(context).focusColor.withOpacity(0.5),
        child: const Icon(Icons.save),
        tooltip: S.of(context).app.save,
        onPressed: disabled ? null : _save,
      ),
      onMove: (f, k, d) {
        switch (d) {
          case TraversalDirection.down:
            _focusNodeBar.requestFocus();
            return KeyEventResult.handled;
          default:
            break;
        }
        return KeyEventResult.ignored;
      },
    );
  }
}
