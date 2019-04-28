import 'package:second_music/model/singer.dart';
import 'package:second_music/model/song.dart';

//专辑
class Album
{
  String plt;
  String source;
  String id;
  String name;
  String subtitle;
  String cover;
  String releaseTime;//发行时间
  String description;//描述

  int playCount; //播放量
  int favorCount; //收藏量

  Singer singer;
  List<Singer> singers;//歌手

  int songTotal;//歌曲的数量
  List<Song> songs;
}