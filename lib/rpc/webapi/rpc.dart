import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:piwigo/utils/enum.dart';
import 'package:piwigo/utils/json.dart';

class PiwigoException implements Exception {
  final dynamic message;
  PiwigoException(this.message);
  @override
  String toString() => 'PiwigoException: $message';
}

class Status {
  String username;
  String status;
  String theme;
  String language;
  String pwgToken;
  String charset;
  String currentDatetime;
  String version;
  List<String> availableSizes;
  String uploadFileTypes;
  int uploadFormChunkSize;
  Status.fromJson(Map<String, dynamic> json)
      : username = json['username'] ?? '',
        status = json['status'] ?? '',
        theme = json['theme'] ?? '',
        language = json['language'] ?? '',
        pwgToken = json['pwg_token'] ?? '',
        charset = json['charset'] ?? '',
        currentDatetime = json['current_datetime'] ?? '',
        version = json['version'] ?? '',
        availableSizes = listFromJson(json['available_sizes']),
        uploadFileTypes = json['upload_file_types'] ?? '',
        uploadFormChunkSize = json['upload_form_chunk_size'] ?? 0;

  @override
  String toString() {
    return 'username=$username status=$status uploadFileTypes=$uploadFileTypes';
  }
}

class ImageSize extends Enum {
  final bool unknow;
  const ImageSize._(
    int value,
    String name, {
    this.unknow = false,
  }) : super(value, name);

  /// 120 x 120
  static const square = ImageSize._(1, 'square');

  /// 144 x ?
  static const thumb = ImageSize._(2, 'thumb');

  /// 240
  static const smallXX = ImageSize._(3, '2small');

  /// 324
  static const smallX = ImageSize._(4, 'xsmall');

  /// 432
  static const small = ImageSize._(5, 'small');

  /// 594
  static const medium = ImageSize._(6, 'medium');

  /// 756
  static const large = ImageSize._(7, 'large');

  /// 1224
  static const largeX = ImageSize._(8, 'xlarge');
  // 1656
  static const largeXX = ImageSize._(9, 'xxlarge');
}

abstract class RpcClient {
  final Dio dio;
  int account;
  final String name;
  final String password;
  Status? status;
  RpcClient({
    required this.dio,
    required this.account,
    required this.name,
    required this.password,
  });
  final String path = 'ws.php';

  /// 最後登入時間
  DateTime? last;
  Map<String, dynamic> queryParameters(String method,
      {Map<String, dynamic>? parameters}) {
    parameters ??= <String, dynamic>{};
    parameters['format'] = 'json';
    parameters['method'] = method;
    return parameters;
  }

  Map<String, dynamic> decodeResponse(String response) {
    final obj = jsonDecode(response);
    final String stat = obj['stat'];
    if (stat != 'ok') {
      throw PiwigoException(response);
    }
    return obj;
  }

  Future<void> login({CancelToken? cancelToken}) async {
    try {
      final resp = await dio.post(
        path,
        queryParameters: queryParameters('pwg.session.login'),
        data: <String, dynamic>{
          'username': name,
          'password': password,
        },
        options: Options(
          headers: <String, dynamic>{
            'Content-Type': 'application/x-www-form-urlencoded'
          },
        ),
        cancelToken: cancelToken,
      );
      decodeResponse(resp.data);
      last = DateTime.now();
      debugPrint("login at $last");
    } on DioError catch (e) {
      throw Exception('${e.message} ${e.response?.data}');
    }
  }

  Future<void> checkLogin({CancelToken? cancelToken}) async {
    if (last == null) {
      await login(cancelToken: cancelToken);
    } else if (DateTime.now().difference(last!) > const Duration(minutes: 30)) {
      await login(cancelToken: cancelToken);
    }
  }
}
