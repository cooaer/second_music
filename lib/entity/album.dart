import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/singer.dart';
import 'package:second_music/entity/song.dart';

//专辑
class Album {
  MusicPlatform plt = MusicPlatform.netease;
  String pltId = "";
  String name = "";
  String subtitle = "";
  String cover = "";
  String description = ""; //描述
  String releaseTime = ""; //发行时间

  int playCount = 0; //播放量
  int favorCount = 0; //收藏量

  Singer? get singer => singers.firstOrNull;

  List<Singer> singers = []; //歌手

  int songTotal = 0; //歌曲的数量
  List<Song> songs = [];

  bool get isValid => pltId.isNotEmpty;

  @override
  String toString() {
    return 'Album{plt: $plt, id: $pltId, name: $name, subtitle: $subtitle, cover: $cover, releaseTime: $releaseTime, description: $description, playCount: $playCount, favorCount: $favorCount, singers: $singers, songTotal: $songTotal, songs: $songs}';
  }
}
