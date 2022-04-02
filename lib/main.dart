import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:piwigo/db/language.dart';
import 'package:piwigo/db/theme.dart';
import 'package:piwigo/i18n/generated_i18n.dart';
import 'package:piwigo/pages/account/account.dart';
import 'package:piwigo/pages/load/add.dart';
import 'package:piwigo/pages/load/load.dart';
import 'package:piwigo/pages/settings/language.dart';
import 'package:piwigo/pages/settings/settings.dart';
import 'package:piwigo/pages/settings/theme.dart';
import 'package:piwigo/routes.dart';
import 'package:ppg_ui/ppg_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MyLanguage.instance.load().then((language) {
    MyTheme.instance.load().then(
          (theme) => runApp(
            MyApp(
              language: language,
              theme: theme,
            ),
          ),
        );
  });
}

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
    required this.theme,
    this.language,
  }) : super(key: key);
  final String theme;
  final String? language;
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends UIState<MyApp> {
  late ThemeMode _themeMode;
  @override
  void initState() {
    super.initState();

    _themeMode = MyTheme.mode(widget.theme);
    var language = widget.language;

    final theme = MyTheme.instance;
    addAllSubscription([
      MyLanguage().subject.listen((v) {
        if (isNotClosed && language != v) {
          setState(() {
            debugPrint("change language to $v");
            language = v;
          });
        }
      }),
      theme.subject.listen((event) {
        if (isNotClosed) {
          final mode = MyTheme.mode(event);
          if (mode != _themeMode) {
            setState(() {
              debugPrint("change theme to $mode");
              _themeMode = mode;
            });
          }
        }
      })
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: MyLanguage.locale,
      localizationsDelegates: const [
        ...GlobalMaterialLocalizations.delegates,
        GlobalWidgetsLocalizations.delegate,
        S.delegate,
      ],
      supportedLocales: supportedLanguage.map((v) => v.locale),
      localeResolutionCallback: MyLanguage.myLocaleResolutionCallback,
      onGenerateTitle: (context) => S.of(context).appName,
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      builder: BotToastInit(),
      initialRoute: MyRoutes.load,
      navigatorObservers: [
        BotToastNavigatorObserver(),
      ],
      routes: {
        MyRoutes.load: (context) => const MyLoadPage(),
        MyRoutes.firstAdd: (context) => const MyAddPage(
              push: true,
            ),
        MyRoutes.add: (context) => const MyAddPage(),

        MyRoutes.account: (context) => const MyAccountPage(),

        // settings
        MyRoutes.settings: (context) => const MySettingsPage(),
        MyRoutes.settingsLanguage: (context) => const MySettingsLanguagePage(),
        MyRoutes.settingsTheme: (context) => const MySettingsThemePage(),
      },
    );
  }
}
