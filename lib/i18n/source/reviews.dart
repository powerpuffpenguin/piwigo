import 'package:intl/intl.dart';

class Reviews {
  const Reviews();

  String get doYouLike => Intl.message(
        'Reviews.doYouLike',
        desc: '到目前為止，您如何看待我們的產品？',
      );
  String get dismiss => Intl.message(
        'Reviews.Dismiss',
        desc: '不再詢問',
      );
  String get like => Intl.message(
        'Reviews.like',
        desc: '喜歡',
      );
  String get dislike => Intl.message(
        'Reviews.dislike',
        desc: '不喜歡',
      );
  String get mayBeNextTime => Intl.message(
        'Reviews.MayBeNextTime',
        desc: '下次再評價',
      );
  String get fantastical => Intl.message(
        'Reviews.fantastical',
        desc: '太棒了！ 您想在商店給我們評級嗎？',
      );
  String get sure => Intl.message(
        'Reviews.Sure',
        desc: '當然！',
      );
  String get noThanks => Intl.message(
        'Reviews.noThanks',
        desc: '不用了',
      );
}
