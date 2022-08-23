import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:second_music/repository/remote/cookie.dart';
import 'package:second_music/repository/remote/http_maker.dart';

final dio = Dio()
  ..options = BaseOptions(connectTimeout: 30 * 1000, receiveTimeout: 30 * 1000)
  ..interceptors.add(LogInterceptor(requestBody: true, responseBody: true))
  ..interceptors.add(CookieManager(cookieJar))
  ..interceptors.add(AddHeaderInterceptor());

Future<ResponseResult> dioGet(String url,
    {Map<String, dynamic>? headers}) async {
  final response =
      await dio.get<String>(url, options: Options(headers: headers));
  return ResponseResult(
      response.statusCode, response.statusMessage, response.data);
}

Future<ResponseResult> dioPost(String url, dynamic data,
    {Map<String, dynamic>? headers}) async {
  final contentType = headers?.remove('Content-Type') ?? "";
  final response = await dio.post<String>(url,
      data: data, options: Options(headers: headers, contentType: contentType));
  return ResponseResult(
      response.statusCode, response.statusMessage, response.data);
}

Future<String> dioGetDefault(String url,
    {Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers}) async {
  try {
    var response = await dio.get<String>(url,
        queryParameters: queryParameters, options: Options(headers: headers));
    return response.data ?? "";
  } on Exception catch (e) {
    debugPrint("dioGetDefault: exception = $e");
  }
  return "";
}

Future<String> dioPostDefault(String url, dynamic data,
    {Map<String, dynamic>? headers}) async {
  try {
    final contentType = headers?.remove('Content-Type');
    final response = await dio.post<String>(url,
        data: data,
        options: Options(headers: headers, contentType: contentType));
    return response.data ?? "";
  } on Exception catch (e) {
    debugPrint("dioPostDefault: exception = $e");
  }
  return "";
}

class AddHeaderInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    var replaceReferer = true;
    var replaceOrigin = true;
    const addReferer = true;
    var addOrigin = true;
    var refererValue = '';

    var url = options.uri.toString();

    if (url.indexOf('://music.163.com/') != -1) {
      refererValue = 'http://music.163.com/';
    }
    if (url.indexOf('://gist.githubusercontent.com/') != -1) {
      refererValue = 'https://gist.githubusercontent.com/';
    }

    if ((url.indexOf('c.y.qq.com/') != -1) ||
        (url.indexOf('i.y.qq.com/') != -1) ||
        (url.indexOf('qqmusic.qq.com/') != -1) ||
        (url.indexOf('music.qq.com/') != -1) ||
        (url.indexOf('imgcache.qq.com/') != -1)) {
      refererValue = 'https://y.qq.com/';
    }

    if (url.indexOf('c.y.qq.com/soso/fcgi-bin/client_search_cp') != -1) {
      refererValue = '';
    }

    if (url.indexOf('c.y.qq.com/soso/fcgi-bin/client_music_search_songlist') !=
        -1) {
      addOrigin = false;
    }

    if (url.indexOf('.kugou.com/') != -1) {
      refererValue = 'http://www.kugou.com/';
    }

    if (url.indexOf('.kuwo.cn/') != -1) {
      refererValue = 'http://www.kuwo.cn/';
    }

    if (url.contains('.bilibili.com/') || url.contains('.bilivideo.com/')) {
      refererValue = 'http://www.bilibili.com/';
      replaceOrigin = false;
      addOrigin = false;
    }

    if (url.contains('.migu.cn')) {
      refererValue = 'https://music.migu.cn/v3/music/player/audio?from=migu';
    }

    if (url.contains('m.music.migu.cn')) {
      refererValue = 'https://m.music.migu.cn/';
    }

    var isRefererSet = false;
    var isOriginSet = false;
    var headers = options.headers;

    if (replaceReferer &&
        headers.containsKey('Referer') &&
        refererValue.isNotEmpty) {
      headers['Referer'] = refererValue;
      isRefererSet = true;
    }

    if (replaceOrigin &&
        headers.containsKey('Origin') &&
        refererValue.isNotEmpty) {
      headers['Origin'] = refererValue;
      isOriginSet = true;
    }

    if (addReferer && !isRefererSet && refererValue.isNotEmpty) {
      headers['Referer'] = refererValue;
    }

    if (addOrigin && !isOriginSet && refererValue.isNotEmpty) {
      headers['Origin'] = refererValue;
    }
    return super.onRequest(options, handler);
  }
}
