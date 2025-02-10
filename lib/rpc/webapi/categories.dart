import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:piwigo/utils/json.dart';

import './rpc.dart';

class Categorie {
  String id;
  String name;

  /// 相冊描述
  String comment;

  /// 永久鏈接
  // String permalink;
  /// 相冊權限
  /// * private
  /// * public
  String status;
  // String uppercats;
  // String global_rank;
  /// 父相冊 id
  String parent;

  /// 相冊照片數
  int images;

  /// 相冊照片數 包括子相冊
  int totalImages;

  /// 代表圖片id
  // String representative_picture_id;
  // String date_last;
  // String max_date_last;

  /// 子相冊數量
  int categories;

  /// 訪問地址
  // String url;

  /// 封面圖地址
  String cover;

  Categorie.fromJson(Map<String, dynamic> json, Uri uri)
      : id = json['id'].toString(),
        name = json['name'] ?? '',
        comment = json['comment'] ?? '',
        status = json['status'] ?? '',
        parent = json['id_uppercat'] ?? '0',
        images = json['nb_images'] ?? 0,
        totalImages = json['total_nb_images'] ?? 0,
        categories = json['nb_categories'] ?? 0,
        cover = copyUri(uri, json['tn_url'] ?? '');
}

String copyUri(Uri uri, String src) {
  if (src == "") {
    return src;
  }
  final s = Uri.parse(src);
  if (s.host == uri.host) {
    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.port,
      userInfo: s.userInfo,
      path: s.path,
      query: s.query == '' ? null : s.query,
      fragment: s.fragment == '' ? null : s.fragment,
    ).toString();
  }
  return src;
}

class PageInfo {
  /// 當前頁數 以 0 爲第一頁
  int page;

  /// 每頁數量
  int pageCount;

  /// 當前頁照片數
  int count;

  /// 照片總數
  String totalCount;
  PageInfo.fromJson(Map<String, dynamic> json)
      : page = json['page'] ?? 0,
        pageCount = json['per_page'] ?? 0,
        count = json['count'] ?? 0,
        totalCount = json['total_count'] ?? '0';

  Map<String, dynamic> toJson() => {
        "page": page,
        "per_page": pageCount,
        "count": count,
        "total_count": totalCount,
      };
  @override
  String toString() => jsonEncode(toJson());

  /// 返回是否已經到最後一頁
  bool completed() {
    if (count == 0) {
      return true;
    }
    try {
      return count + page * pageCount >= int.parse(totalCount);
    } catch (e) {
      debugPrint("PageInfo.completed at int.parse($totalCount) error: $e");
      return false;
    }
  }
}

class Derivative {
  String url;
  int width;
  int height;
  Derivative({
    required this.url,
    required this.width,
    required this.height,
  });
  Derivative.fromJson(Map<String, dynamic> json, Uri uri)
      : url = copyUri(uri, json['url'] ?? ''),
        width = intFromJson(json['width']),
        height = intFromJson(json['height']);

  bool match(int w, int h) => width >= w || height >= h;
}

class Derivatives {
  Derivative square;
  Derivative thumb;
  Derivative smallXX;
  Derivative smallX;
  Derivative small;
  Derivative medium;
  Derivative large;
  Derivative largeX;
  Derivative largeXX;

  Derivatives.fromJson(Map<String, dynamic> json, Uri uri)
      : square = Derivative.fromJson(json['square'], uri),
        thumb = Derivative.fromJson(json['thumb'], uri),
        smallXX = Derivative.fromJson(json['2small'], uri),
        smallX = Derivative.fromJson(json['xsmall'], uri),
        small = Derivative.fromJson(json['small'], uri),
        medium = Derivative.fromJson(json['medium'], uri),
        large = Derivative.fromJson(json['large'], uri),
        largeX = Derivative.fromJson(json['xlarge'], uri),
        largeXX = Derivative.fromJson(json['xxlarge'], uri);
}

class PageImage {
  String id;
  int width;
  int height;
  // int hit;
  /// 檔案名稱
  String file;

  /// 照片名稱
  String name;

  /// 照片描述
  String comment;
  //  String date_creation;
  // String date_available;
  // 照片查看網頁地址
  // page_url

  /// 原始圖像地址
  String url;

  /// 衍生的照片
  Derivatives derivatives;

  Derivative getDerivative(int width, int height) {
    if (derivatives.smallXX.match(width, height)) {
      return derivatives.smallXX;
    } else if (derivatives.smallX.match(width, height)) {
      return derivatives.smallX;
    } else if (derivatives.small.match(width, height)) {
      return derivatives.small;
    } else if (derivatives.medium.match(width, height)) {
      return derivatives.medium;
    } else if (derivatives.large.match(width, height)) {
      return derivatives.large;
    } else if (derivatives.largeX.match(width, height)) {
      return derivatives.largeX;
    }
    return derivatives.largeXX;
  }

  // categories:Array 所屬相冊
  static List<PageImage> fromJsonList(List? v, Uri uri) {
    return v?.map((e) => PageImage.fromJson(e, uri)).toList() ?? <PageImage>[];
  }

  PageImage.fromJson(Map<String, dynamic> json, Uri uri)
      : id = json['id']?.toString() ?? '0',
        width = json['width'] ?? 0,
        height = json['height'] ?? 0,
        file = json['file'] ?? '',
        name = json['name'] ?? '',
        comment = json['comment'] ?? '',
        url = copyUri(uri, json['element_url'] ?? ''),
        derivatives = Derivatives.fromJson(json['derivatives'], uri);

  static String getSquare(PageImage node) => node.derivatives.square.url;
  static String getThumb(PageImage node) => node.derivatives.thumb.url;
  static String getSmallXX(PageImage node) => node.derivatives.smallXX.url;
  static String getSmallX(PageImage node) => node.derivatives.smallX.url;
  static String getSmall(PageImage node) => node.derivatives.small.url;
  static String getMedium(PageImage node) => node.derivatives.medium.url;
  static String getLarge(PageImage node) => node.derivatives.large.url;
  static String getLargeX(PageImage node) => node.derivatives.largeX.url;
  static String getLargeXX(PageImage node) => node.derivatives.largeXX.url;
}

class PageImages {
  PageInfo pageInfo;
  List<PageImage> list;
  PageImages.fromJson(Map<String, dynamic> json, Uri uri)
      : pageInfo = PageInfo.fromJson(json['paging']),
        list = PageImage.fromJsonList(json['images'], uri);
}

mixin Categories on RpcClient {
  /// 返回相册列表
  Future<List<Categorie>> getCategoriesList({
    String parent = '0',
    ImageSize thumbSize = ImageSize.smallXX,
    CancelToken? cancelToken,
  }) async {
    try {
      await checkLogin(cancelToken: cancelToken);
      final resp = await dio.get(
        path,
        queryParameters: queryParameters(
          'pwg.categories.getList',
          parameters: <String, dynamic>{
            'cat_id': parent,
            'thumbnail_size': thumbSize.toString()
          },
        ),
        cancelToken: cancelToken,
      );

      final obj = decodeResponse(resp.data);
      final List? list = obj['result']['categories'];
      final result = <Categorie>[];
      final uri = Uri.parse(dio.options.baseUrl);
      list?.forEach((v) {
        final node = Categorie.fromJson(v, uri);
        if (node.id != parent) {
          result.add(node);
          // debugPrint('cover: ${node.cover}');
        }
      });
      return result;
    } on DioError catch (e) {
      throw Exception('${e.message} ${e.response?.data}');
    }
  }

  /// 返回相册中的照片
  /// order -> id, file, name, hit, rating_score, date_creation, date_available, random
  Future<PageImages> getCategoriesImages({
    required String parent,
    int pageCount = 100,
    int page = 0,
    String? order,
    CancelToken? cancelToken,
  }) async {
    try {
      await checkLogin(cancelToken: cancelToken);
      final resp = await dio.get(
        path,
        queryParameters: queryParameters(
          'pwg.categories.getImages',
          parameters: <String, dynamic>{
            'cat_id': parent,
            'per_page': pageCount,
            'page': page,
            'order': order,
          },
        ),
        cancelToken: cancelToken,
      );
      final obj = decodeResponse(resp.data);
      return PageImages.fromJson(obj['result'], Uri.parse(dio.options.baseUrl));
    } on DioError catch (e) {
      throw Exception('${e.message} ${e.response?.data}');
    }
  }
}
