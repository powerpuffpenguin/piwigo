import 'package:dio/dio.dart';
import 'package:piwigo/rpc/webapi/categories.dart';
import 'package:piwigo/rpc/webapi/client.dart';

class Source {
  /// 是否正在請求頁面數據
  bool _request = false;
  bool get request => _request;

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
