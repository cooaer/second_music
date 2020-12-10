import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/singer.dart';
import 'package:second_music/entity/song.dart';

//专辑
class Album {
  MusicPlatform plt = MusicPlatform.netease;
  String source = "";
  String id = "";
  String name = "";
  String subtitle = "";
  String cover = "";
  String releaseTime = ""; //发行时间
  String description = ""; //描述

  int playCount = 0; //播放量
  int favorCount = 0; //收藏量

  List<Singer> singers = []; //歌手
  Singer? get singer => singers.firstOrNull;

  int songTotal = 0; //歌曲的数量
  List<Song> songs = [];

  @override
  String toString() {
    return 'Album{plt: $plt, source: $source, id: $id, name: $name, subtitle: $subtitle, cover: $cover, releaseTime: $releaseTime, description: $description, playCount: $playCount, favorCount: $favorCount, singers: $singers, songTotal: $songTotal, songs: $songs}';
  }
}
