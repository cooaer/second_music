import 'dart:convert';

import 'package:second_music/model/enum.dart';
import 'package:second_music/model/song.dart';
import 'package:second_music/storage/preference/basic.dart';

class PlayingStorage {
  static PlayingStorage _instance;

  static PlayingStorage get instance {
    if (_instance == null) {
      _instance = PlayingStorage._();
    }
    return _instance;
  }

  PlayingStorage._();

  /// 当前播放列表

  static const PLAYING_LIST = 'playing_list';

  Future<bool> savePlayingList(List<Song> songs) async {
    var list = songs.map((item) => json.encode(item.toPreference())).toList();
    return await sharedPreferences.setStringList(PLAYING_LIST, list);
  }

  List<Song> playingList() {
    return sharedPreferences
            .getStringList(PLAYING_LIST)
            ?.map((item) => Song.fromPreference(json.decode(item)))
            ?.toList() ??
        [];
  }

  /// 当前播放歌曲位置
  static const PLAYING_INDEX = 'play_index';

  Future<bool> savePlayingIndex(int index) async {
    return await sharedPreferences.setInt(PLAYING_INDEX, index);
  }

  int playingIndex() {
    return sharedPreferences.getInt(PLAYING_INDEX) ?? -1;
  }

  /// 播放模式
  static const PLAY_MODE = 'play_mode';

  Future<bool> savePlayMode(PlayMode playMode) async {
    return await sharedPreferences.setInt(PLAY_MODE, playMode.index);
  }

  PlayMode playMode() {
    var index = sharedPreferences.getInt(PLAY_MODE) ?? 0;
    return PlayMode.values[index];
  }

  static const SEARCH_KEYWORDS = 'search_keywords';

  Future<bool> saveSearchKeywords(List<String> keywords){
    return sharedPreferences.setStringList(SEARCH_KEYWORDS, keywords);
  }

  List<String> searchKeywords(){
    return sharedPreferences.getStringList(SEARCH_KEYWORDS) ?? <String>[];
  }

}
