import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:second_music/common/path.dart';

var cookieJar = PersistCookieJar(
    ignoreExpires: true,
    storage: FileStorage(AppPath.instance.tempCookieDirPath));

Future<void> setCookie(String url, String name, String value, int expire) {
  return cookieJar.saveFromResponse(Uri.parse(url), [
    Cookie(name, value)..expires = DateTime.fromMillisecondsSinceEpoch(expire)
  ]);
}
