import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class AppPath{

  String _tempDirPath;
  String _tempCookieDirPath;

  String get tempDirPath => _tempDirPath;
  String get tempCookieDirPath => _tempCookieDirPath;

  static AppPath _instance;

  static AppPath get instance{
    if(_instance == null){
      _instance = AppPath._();
    }
    return _instance;
  }

  AppPath._();

  Future init() async{
    var tempDir = await getTemporaryDirectory();
    _tempDirPath = tempDir.path;
    var _tempCookieDir = Directory(path.join(_tempDirPath, 'cookies'));
    await _tempCookieDir.create();
    _tempCookieDirPath = _tempCookieDir.path;
  }


}