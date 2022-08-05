import 'package:second_music/repository/remote/dio_http.dart';

enum HttpMethod { get, post }

class HttpMakerParams {
  static const url = 'url';
  static const method = 'method';
  static const data = 'data';
  static const headers = "headers";
  static const methodGet = 'get';
  static const methodPost = 'post';
}

typedef T HttpMaker<T>(Map<String, dynamic> params);

Future<ResponseResult> dioHttpMaker(Map<String, dynamic> params) {
  final String url = params.remove(HttpMakerParams.url);
  HttpMethod method = params.remove(HttpMakerParams.method);
  final String data = params.remove(HttpMakerParams.data);
  final Map<String, String> headers = params.remove(HttpMakerParams.headers);
  switch (method) {
    case HttpMethod.get:
      return dioGet(url);
    case HttpMethod.post:
      return dioPost(url, data, headers);
  }
}

Future<String> dioHttpMakerDefault(Map<String, dynamic> params) async {
  final String url = params.remove(HttpMakerParams.url);
  String method = params.remove(HttpMakerParams.method);
  final data = params.remove(HttpMakerParams.data);
  final Map<String, String>? headers = params.remove(HttpMakerParams.headers);
  switch (method) {
    case "get":
      return await dioGetDefault(url, queryParameters: data);
    case "post":
      return await dioPostDefault(url, data, headers);
  }
  return "";
}

class ResponseResult<String> {
  final int? code;
  final String? msg;
  final String? data;

  ResponseResult(this.code, this.msg, this.data);
}
