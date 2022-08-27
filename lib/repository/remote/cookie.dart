import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:second_music/common/path.dart';

var cookieJar = PersistCookieJar(
    ignoreExpires: true,
    storage: FileStorage(AppPath.instance.tempCookieDirPath));

Future<void> setCookie(
    String url, String name, String value, int expire) async {
  return cookieJar.saveFromResponse(Uri.parse(url), [
    Cookie(name, value)..expires = DateTime.fromMillisecondsSinceEpoch(expire)
  ]);
}

Future<Cookie?> getCookie(String url, String name) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    return null;
  }
  return (await cookieJar.loadForRequest(uri))
      .firstWhereOrNull((cookie) => cookie.name == name);
}
