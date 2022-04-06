import 'package:flutter/material.dart';

class MyRoutes {
  MyRoutes._();
  static const String dev = "/dev";
  static const String load = "/load";
  static const String firstAdd = "/firstAdd";
  static const String add = "/add";

  static const String settings = "/settings";
  static const String settingsLanguage = "/settings/language";
  static const String settingsTheme = "/settings/theme";
  static const String settingsVideo = "/settings/video";

  static const String account = "/account";

  static bool clearRoutes(Route<dynamic> route) => false;
}
