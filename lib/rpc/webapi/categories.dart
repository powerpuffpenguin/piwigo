import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';

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

  Categorie.fromJson(Map<String, dynamic> json)
      : id = json['id'].toString(),
        name = json['name'] ?? '',
        comment = json['comment'] ?? '',
        status = json['status'] ?? '',
        parent = json['id_uppercat'] ?? '0',
        images = json['nb_images'] ?? 0,
        totalImages = json['total_nb_images'] ?? 0,
        categories = json['nb_categories'] ?? 0,
        cover = json['tn_url'] ?? '';
}

mixin Categories on RpcClient {
  Future<List<Categorie>> getCategoriesList({
    String parent = '0',
    ImageSize thumbSize = ImageSize.smallXX,
  }) async {
    try {
      final resp = await dio.get(
        path,
        queryParameters: queryParameters(
          'pwg.categories.getList',
          parameters: <String, dynamic>{
            'cat_id': parent,
            'thumbnail_size': thumbSize.toString()
          },
        ),
      );
      final obj = decodeResponse(resp.data);
      final List? list = obj['result']['categories'];
      final result = <Categorie>[];
      list?.forEach((v) {
        final node = Categorie.fromJson(v);
        if (node.id != parent) {
          result.add(node);
          debugPrint('cover: ${node.cover}');
        }
      });
      return result;
    } on DioError catch (e) {
      throw Exception('${e.message} ${e.response?.data}');
    }
  }
}
