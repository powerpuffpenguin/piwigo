class MyEnvironment {
  MyEnvironment._();

  static const String applicationLegalese = "© 2022 The Piwigo";
  static String get packageName => "com.king011.piwigo";
  static String get playStore =>
      'https://play.google.com/store/apps/details?id=$packageName';

  // static String version = "v0.0.1";
  static String version = "v0.0.4";

  static bool get isProduct => const bool.fromEnvironment("dart.vm.product");
  static bool get isDebug => !isProduct;

  static noWork() {}
  static Duration get delayDuration => const Duration(milliseconds: 500);
  static Duration get timeoutDuration => const Duration(seconds: 30);

  static const double viewPadding = 14;
  static const double spacing = 10;

  static String datetimeToString(DateTime dateTime) =>
      "${dateTime.year.toString()}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
  static String durationToString(Duration duration) => duration.inDays > 0
      ? "${duration.inDays} days ${duration.inHours.remainder(24).toString().padLeft(2, '0')}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}"
      : "${duration.inHours.toString().padLeft(2, '0')}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}";
}
