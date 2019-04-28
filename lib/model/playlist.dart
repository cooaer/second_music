import 'package:second_music/model/song.dart';
import 'package:second_music/model/song_list.dart';
import 'package:second_music/model/user.dart';

//歌单
class Playlist {
  String plt;
  String source;

  ///自己创建的歌单的ID为时间戳，收藏别人的歌单的ID为该平台上对应的ID
  String id;
  String cover;
  String title;
  int playCount; //播放量
  int favorCount; //收藏量
  String description; //描述

  SongListType type;

  ///创建者，plt,id,name,avatar,source
  User creator;

  int songTotal;
  List<Song> songs;
}
