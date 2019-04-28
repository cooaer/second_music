import 'package:cookie_jar/cookie_jar.dart';
import 'package:second_music/common/path.dart';

var cookieJar = PersistCookieJar(dir: AppPath.instance.tempCookieDirPath);