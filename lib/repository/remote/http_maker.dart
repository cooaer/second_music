import 'package:second_music/repository/remote/dio_http.dart';

abstract class HttpMaker {
  factory HttpMaker() {
    return DioHttpMaker();
  }

  Future<String> get(String url,
      {Map<String, dynamic>? queryParameters, Map<String, dynamic>? headers});

  Future<String> post(String url, dynamic data,
      {Map<String, dynamic>? headers});
}

class DioHttpMaker implements HttpMaker {
  @override
  Future<String> get(String url,
      {Map<String, dynamic>? queryParameters, Map<String, dynamic>? headers}) {
    return dioGetDefault(url,
        queryParameters: queryParameters, headers: headers);
  }

  @override
  Future<String> post(String url, dynamic data,
      {Map<String, dynamic>? headers}) {
    return dioPostDefault(url, data, headers: headers);
  }
}

class ResponseResult<String> {
  final int? code;
  final String? msg;
  final String? data;

  ResponseResult(this.code, this.msg, this.data);
}
