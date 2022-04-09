import 'package:intl/intl.dart';

class Download {
  const Download();
  String get browseProgress => Intl.message(
        'Download.browseProgress',
        desc: '瀏覽進度',
      );
  String get categorie => Intl.message(
        'Download.categorie',
        desc: '下載相冊',
      );
  String get photo => Intl.message(
        'Download.photo',
        desc: '下載照片',
      );
}
