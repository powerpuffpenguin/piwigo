import 'package:intl/intl.dart';

class Photo {
  const Photo();
  String get next => Intl.message(
        'Photo.next',
        desc: '下一個',
      );
  String get before => Intl.message(
        'Photo.before',
        desc: '上一個',
      );

  String get resize => Intl.message(
        'Photo.resize',
        desc: '圖片大小',
      );
  String get smallXX => Intl.message(
        'Photo.smallXX',
        desc: '極小',
      );
  String get smallX => Intl.message(
        'Photo.smallX',
        desc: '超小',
      );
  String get small => Intl.message(
        'Photo.small',
        desc: '小',
      );
  String get medium => Intl.message(
        'Photo.medium',
        desc: '中',
      );
  String get large => Intl.message(
        'Photo.large',
        desc: '大',
      );
  String get largeX => Intl.message(
        'Photo.largeX',
        desc: '超大',
      );
  String get largeXX => Intl.message(
        'Photo.largeXX',
        desc: '巨大',
      );
  String get original => Intl.message(
        'Photo.original',
        desc: '原始',
      );
  String get video => Intl.message(
        'Photo.video',
        desc: '視頻',
      );
  String get download => Intl.message(
        'Photo.download',
        desc: '下載',
      );
  String get upload => Intl.message(
        'Photo.upload',
        desc: '上傳',
      );
}
