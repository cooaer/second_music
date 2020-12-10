import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class AppPath {
  String? _tempDirPath;
  String? _tempCookieDirPath;

  String get tempDirPath => _tempDirPath ?? "";

  String get tempCookieDirPath => _tempCookieDirPath ?? "";

  static AppPath? _instance = null;

  static AppPath get instance {
    if (_instance == null) {
      _instance = AppPath._();
    }
    return _instance!;
  }

  AppPath._();

  Future init() async {
    var tempDir = await getTemporaryDirectory();
    _tempDirPath = tempDir.path;
    var _tempCookieDir = Directory(path.join(tempDir.path, 'cookies'));
    await _tempCookieDir.create();
    _tempCookieDirPath = _tempCookieDir.path;
  }
}
