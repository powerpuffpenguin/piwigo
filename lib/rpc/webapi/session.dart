import 'package:dio/dio.dart';

import './rpc.dart';

mixin Session on RpcClient {
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
