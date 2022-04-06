import 'package:intl/intl.dart';
import './source/app.dart';
import './source/settings.dart';
import './source/reviews.dart';
import './source/account.dart';
import './source/photo.dart';

mixin AppResource {
  String get appName => Intl.message('App Name');
  String idae(name) => Intl.message(
        "$name is an idae",
        name: "idae",
        args: [name],
        desc: "example for message input args",
        examples: const {
          "name": "cerberus",
        },
      );

  App get app => const App();
  Account get account => const Account();
  Photo get photo => const Photo();
  Reviews get reviews => const Reviews();
  Error get error => const Error();
  Home get home => const Home();

  Settings get settings => const Settings();
  SettingsLanguage get settingsLanguage => const SettingsLanguage();
  SettingsVideo get settingsVideo => const SettingsVideo();
}
