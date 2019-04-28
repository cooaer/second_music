import 'package:dio/dio.dart';
import 'package:second_music/network/cookie.dart';

final dio = Dio()
  ..options = BaseOptions(connectTimeout: 30 * 1000, receiveTimeout: 30 * 1000)
  ..interceptors.add(LogInterceptor(requestBody: true, responseBody: true))
  ..interceptors.add(CookieManager(cookieJar))
  ..interceptors.add(AddHeaderInterceptor());

Future<T> dioGet<T>(String url) async {
  var response = await dio.get<T>(url);
  return response.data;
}

Future<T> dioPost<T>(String url, Map<String, String> params) async {
  var response = await dio.post(url, queryParameters: params);
  return response.data;
}

class AddHeaderInterceptor extends Interceptor {
  @override
  onRequest(RequestOptions options) {
    const replace_referer = true;
    var replace_origin = true;
    const add_referer = true;
    var add_origin = true;
    var referer_value = '';

    var url = options.uri.toString();

    if (url.indexOf('://music.163.com/') != -1) {
      referer_value = 'http://music.163.com/';
    }
    if (url.indexOf('://gist.githubusercontent.com/') != -1) {
      referer_value = 'https://gist.githubusercontent.com/';
    }

    if (url.indexOf('api.xiami.com/') != -1 ||
        url.indexOf('.xiami.com/song/playlist/id/') != -1 ||
        url.indexOf('www.xiami.com/api/') != -1) {
      add_origin = false;
      referer_value = 'https://www.xiami.com';
    }

    if (url.indexOf('www.xiami.com/api/search/searchSongs') != -1) {
      var key = RegExp(r'key%22:%22(.*?)%22').stringMatch(url);
      add_origin = false;
      referer_value = 'https://www.xiami.com/search?key=${key}';
    }

    if ((url.indexOf('c.y.qq.com/') != -1) ||
        (url.indexOf('i.y.qq.com/') != -1) ||
        (url.indexOf('qqmusic.qq.com/') != -1) ||
        (url.indexOf('music.qq.com/') != -1) ||
        (url.indexOf('imgcache.qq.com/') != -1)) {
      referer_value = 'https://y.qq.com/';
    }

    if(url.indexOf('c.y.qq.com/soso/fcgi-bin/client_search_cp') != -1){
      referer_value = '';
    }

    if(url.indexOf('c.y.qq.com/soso/fcgi-bin/client_music_search_songlist') != -1){
      add_origin = false;
    }

    if (url.indexOf('.kugou.com/') != -1) {
      referer_value = 'http://www.kugou.com/';
    }

    if (url.indexOf('.kuwo.cn/') != -1) {
      referer_value = 'http://www.kuwo.cn/';
    }

    if (url.indexOf('.bilibili.com/') != -1) {
      referer_value = 'http://www.bilibili.com/';
      replace_origin = false;
      add_origin = false;
    }

    var isRefererSet = false;
    var isOriginSet = false;
    var headers = options.headers;

    if (replace_referer && headers.containsKey('Referer') && referer_value.isNotEmpty) {
      headers['Referer'] = referer_value;
      isRefererSet = true;
    }

    if (replace_origin && headers.containsKey('Origin') && referer_value.isNotEmpty) {
      headers['Origin'] = referer_value;
      isOriginSet = true;
    }

    if (add_referer && !isRefererSet && referer_value.isNotEmpty) {
      headers['Referer'] = referer_value;
    }

    if (add_origin && !isOriginSet && referer_value.isNotEmpty) {
      headers['Origin'] = referer_value;
    }
    return super.onRequest(options);
  }
}
