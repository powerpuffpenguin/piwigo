import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:piwigo/db/quality.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/widget/spin.dart';
import 'package:piwigo/pages/widget/state.dart';
import 'package:piwigo/tv/focusable.dart';

class MySettingsQualityPage extends StatefulWidget {
  const MySettingsQualityPage({
    Key? key,
  }) : super(key: key);
  @override
  _MySettingsQualityPageState createState() => _MySettingsQualityPageState();
}

class _MySettingsQualityPageState extends MyState<MySettingsQualityPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(enabled),
      child: _build(context),
    );
  }

  _save(String v) async {
    final myQuality = MyQuality.instance;
    if (myQuality.data == v) {
      return;
    }
    setState(() {
      disabled = true;
    });
    try {
      await myQuality.setData(v);
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

  Widget _build(BuildContext context) {
    final data = MyQuality.instance.data;
    return Scaffold(
      appBar: AppBar(
        leading: FocusableWidget(
          child: BackButton(
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        title: Text(S.of(context).settings.theme),
      ),
      body: ListView(
        children: [
          FocusableWidget(
            child: ListTile(
              leading: data == qualityFast
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).indicatorColor,
                    )
                  : const Icon(Icons.image),
              title: Text(S.of(context).settingsQuality.fast),
              onTap: () => _save(qualityFast),
            ),
          ),
          FocusableWidget(
            child: ListTile(
              leading: data == qualityNormal
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).indicatorColor,
                    )
                  : const Icon(Icons.image),
              title: Text(S.of(context).settingsQuality.normal),
              onTap: () => _save(qualityNormal),
            ),
          ),
          FocusableWidget(
            child: ListTile(
              leading: data == qualityQuality
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).indicatorColor,
                    )
                  : const Icon(Icons.image),
              title: Text(S.of(context).settingsQuality.quality),
              onTap: () => _save(qualityQuality),
            ),
          ),
          FocusableWidget(
            child: ListTile(
              leading: data == qualityRaw
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).indicatorColor,
                    )
                  : const Icon(Icons.image),
              title: Text(S.of(context).settingsQuality.raw),
              onTap: () => _save(qualityRaw),
            ),
          ),
        ],
      ),
      floatingActionButton: disabled ? createSpinFloating() : null,
    );
  }
}
