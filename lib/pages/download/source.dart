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

  Future<bool> getImages(
    Client client, {
    required String parent,
    int pageCount = 100,
    int page = 0,
    CancelToken? cancelToken,
  }) async {
    if (_request) {
      return false;
    }
    _request = true;
    try {
      final images = await client.getCategoriesImages(
        parent: parent,
        page: page,
        cancelToken: cancelToken,
        // pageCount: 30,
      );
      return true;
    } finally {
      _request = false;
    }
  }
}
