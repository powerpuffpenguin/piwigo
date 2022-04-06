import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool reverse = false;
  double scaled = 0;
  final _scaleController = TextEditingController();
  final _rotateController = TextEditingController();

  _onSelect(MyFocusNode focused) {
    if (focused.isArrowBack) {
      Navigator.of(context).pop();
    } else if (focused.id == 'scale') {
      nextFocus('rotate');
    } else if (focused.id == 'rotate') {
      nextFocus('save');
    } else if (focused.id == 'save') {
      _save();
    } else if (focused.id == 'reverse') {
      setState(() {
        reverse = !reverse;
      });
    }
  }

  _save() {
    setState(() {
      disabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyKeyboardListener(
      focusNode: createFocusNode('MyKeyboardListener'),
      child: _build(context),
      onSelected: disabled
          ? null
          : () {
              final focused = focusedNode();
              if (focused == null) {
                return;
              }
              _onSelect(focused);
            },
    );
  }

  Widget _build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backOfAppBar(context),
        title: Text(S.of(context).settingsVideo.title),
      ),
      body: ListView(
        children: [
          FocusScope(
            node: focusScopeNode,
            child: SwitchListTile(
              focusNode: createFocusNode('reverse'),
              title: Text(S.of(context).settingsVideo.reverse),
              value: reverse,
              onChanged: disabled
                  ? null
                  : (val) {
                      setState(() {
                        reverse = val;
                      });
                    },
            ),
          ),
          FocusScope(
            node: focusScopeNode,
            child: TextField(
              enabled: enabled,
              focusNode: createFocusNode('scale'),
              controller: _scaleController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.scale),
                label: Text(S.of(context).settingsVideo.scale),
              ),
              onEditingComplete: () {
                nextFocus('rotate');
              },
            ),
          ),
          FocusScope(
            node: focusScopeNode,
            child: TextField(
              enabled: enabled,
              focusNode: createFocusNode('rotate'),
              controller: _rotateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.rotate_90_degrees_cw),
                label: Text(S.of(context).settingsVideo.rotate),
              ),
              onEditingComplete: () {
                nextFocus('save');
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
    );
  }
}
