import 'package:piwigo/rpc/webapi/categories.dart';

class Source {
  final list = <PageImage>[];
  final keys = <String, PageImage>{};
  PageInfo? pageinfo;

  void add(PageImage value) {
    if (keys.containsKey(value.id)) {
      return;
    }
    keys[value.id] = value;
    list.add(value);
  }

  void addAll(Iterable<PageImage> iterable) {
    for (var item in iterable) {
      add(item);
    }
  }
}
