import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/song.dart';
import 'package:second_music/repository/local/preference/basic.dart';

class PlayingStorage {
  static PlayingStorage? _instance = null;

  static PlayingStorage get instance {
    if (_instance == null) {
      _instance = PlayingStorage._();
    }
    return _instance!;
  }

  PlayingStorage._();

  /// 当前播放列表
  static const PLAYING_LIST = 'playing_list';

  Future<bool> savePlayingList(List<Song> songs) async {
    var list = songs.map((item) => json.encode(item.toMap())).toList();
    return await sharedPreferences.setStringList(PLAYING_LIST, list);
  }

  List<Song> playingList() {
    return sharedPreferences
            .getStringList(PLAYING_LIST)
            ?.map((item) => Song.fromMap(json.decode(item)))
            .toList() ??
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

  PlayMode get playMode {
    var index = sharedPreferences.getInt(PLAY_MODE) ?? 0;
    return PlayMode.values[index];
  }

  static const SEARCH_KEYWORDS = 'search_keywords';

  Future<bool> saveSearchKeywords(List<String> keywords) {
    return sharedPreferences.setStringList(SEARCH_KEYWORDS, keywords);
  }

  List<String> get searchKeywords {
    return sharedPreferences.getStringList(SEARCH_KEYWORDS) ?? <String>[];
  }

  static const PLAYING_SONG_ID = "playing_song_id";

  Future<bool> savePlayingSongId(int songId) {
    return sharedPreferences.setInt(PLAYING_SONG_ID, songId);
  }

  int get playingSongId => sharedPreferences.getInt(PLAYING_SONG_ID) ?? 0;

  static const PLAYING_SONG_POSITION = "playing_song_position";

  Future<bool> savePlayingSongPosition(value) {
    // debugPrint("savePlayingSongPosition, value = $value");
    return sharedPreferences.setInt(PLAYING_SONG_POSITION, value);
  }

  int get playingSongPosition {
    final value = sharedPreferences.getInt(PLAYING_SONG_POSITION) ?? 0;
    // debugPrint("get playingSongPosition, value = $value");
    return value;
  }
}
