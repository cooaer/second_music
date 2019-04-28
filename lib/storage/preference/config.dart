import 'dart:async';

import 'package:second_music/model/enum.dart';
import 'package:second_music/storage/preference/basic.dart';

class AppConfig {

  //单例
  static AppConfig _instance;

  static AppConfig get instance{
    if(_instance == null){
      _instance = AppConfig._();
    }
    return _instance;
  }

  AppConfig._();

  //平台排名
  static const platform_rank = 'platform_rank';

  var _platformRankController = StreamController<List<String>>.broadcast();

  Stream<List<String>> get platformRankStream => _platformRankController.stream.map((item) => item);

  List<String> get platformRank {
    var result = sharedPreferences.getStringList(platform_rank);
    return (result != null && result.isNotEmpty) ? result : MusicPlatforms.platforms;
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

  List<String> get searchPltRank {
    var result = sharedPreferences.getStringList(search_platform_rank);
    return result ?? MusicPlatforms.platforms;
  }

  Future<bool> saveSearchPltRank(List<String> pltList) {
    return sharedPreferences.setStringList(search_platform_rank, pltList);
  }

}
