import 'package:second_music/entity/album.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/song.dart';

class Singer {
  MusicPlatform plt = MusicPlatform.netease; //歌手来源平台
  String source = ""; //歌手主页
  String id = "";
  String name = ""; //歌手名称
  String avatar = "";
  String introduction = ""; //歌手简介

  int songTotal = 0;
  List<Song> songs = []; //热门歌曲
  int albumTotal = 0;
  List<Album> albums = [];

  @override
  String toString() {
    return 'Singer{plt: $plt, source: $source, id: $id, name: $name, avatar: $avatar, introduction: $introduction, songTotal: $songTotal, songs: $songs, albumTotal: $albumTotal, albums: $albums}';
  } //专辑

}
