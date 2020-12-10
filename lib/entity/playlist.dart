import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/song.dart';
import 'package:second_music/entity/song_list.dart';
import 'package:second_music/entity/user.dart';

//歌单
class Playlist {
  MusicPlatform plt = MusicPlatform.netease;
  String source = "";

  ///自己创建的歌单的ID为时间戳，收藏别人的歌单的ID为该平台上对应的ID
  String id = "";
  String cover = "";
  String title = "";
  int playCount = 0; //播放量
  int favorCount = 0; //收藏量
  String description = ""; //描述

  SongListType type = SongListType.playlist;

  ///创建者，plt,id,name,avatar,source
  User? creator;

  int songTotal = 0;
  List<Song> songs = [];
}
