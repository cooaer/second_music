import 'dart:async';

import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/repository/local/preference/basic.dart';

class AppConfig {
  //单例
  static AppConfig? _instance;

  static AppConfig get instance {
    if (_instance == null) {
      _instance = AppConfig._();
    }
    return _instance!;
  }

  AppConfig._();

  //平台排名
  static const platform_rank = 'platform_rank';

  var _platformRankController = StreamController<List<String>>.broadcast();

  Stream<List<String>> get platformRankStream =>
      _platformRankController.stream.map((item) => item);

  List<MusicPlatform> get platformRank {
    var result = sharedPreferences.getStringList(platform_rank);
    return result.isNotNullOrEmpty()
        ? result!
            .map((e) => MusicPlatforms.fromString(e))
            .whereType<MusicPlatform>()
            .toList()
        : MusicPlatform.values;
  }

  Future<bool> savePlatformRank(List<String> pltList) async {
    bool result = await sharedPreferences.setStringList(platform_rank, pltList);
    if (result) {
      _platformRankController.add(pltList);
    }
    return result;
  }

  //平台排名
  static const search_platform_rank = 'search_platform_rank';

  List<MusicPlatform> get searchPltRank {
    var result = sharedPreferences.getStringList(search_platform_rank);
    return result.isNotNullOrEmpty()
        ? result!
            .map((e) => MusicPlatforms.fromString(e))
            .whereType<MusicPlatform>()
            .toList()
        : MusicPlatform.values;
  }

  Future<bool> saveSearchPltRank(List<String> pltList) {
    return sharedPreferences.setStringList(search_platform_rank, pltList);
  }
}
