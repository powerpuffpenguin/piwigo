import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import './rpc.dart';
import './session.dart';
import './categories.dart';

class Client extends RpcClient with Session, Categories {
  Client({
    required int account,
    required String baseUrl,
    required String name,
    required String password,
  }) : super(
          dio: Dio()
            ..options.baseUrl = baseUrl.endsWith('/') ? baseUrl : baseUrl + '/'
            ..interceptors.add(CookieManager(CookieJar(ignoreExpires: true))),
          account: account,
          name: name,
          password: password,
        );
}
