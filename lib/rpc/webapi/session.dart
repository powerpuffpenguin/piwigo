import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';

import './rpc.dart';

mixin Session on RpcClient {
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
    } on DioError catch (e) {
      throw Exception('${e.message} ${e.response?.data}');
    }
  }

  Future<Status> getStatus({
    CancelToken? cancelToken,
  }) async {
    try {
      final resp = await dio.get(
        path,
        queryParameters: queryParameters('pwg.session.getStatus'),
        cancelToken: cancelToken,
      );
      final obj = decodeResponse(resp.data);
      resp.headers.forEach((k, v) {
        debugPrint("$k=$v");
      });
      return Status.fromJson(obj['result']);
    } on DioError catch (e) {
      throw Exception('${e.message} ${e.response?.data}');
    }
  }

  Future<void> logout({
    CancelToken? cancelToken,
  }) async {
    try {
      final resp = await dio.post(
        path,
        queryParameters: queryParameters('pwg.session.logout'),
        cancelToken: cancelToken,
        options: Options(
          headers: <String, dynamic>{
            'Content-Type': 'application/x-www-form-urlencoded'
          },
        ),
      );
      decodeResponse(resp.data);
    } on DioError catch (e) {
      throw Exception('${e.message} ${e.response?.data}');
    }
  }
}
