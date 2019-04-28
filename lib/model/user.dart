import 'package:second_music/model/playlist_set.dart';

class User{
  String plt;
  String source;

  String id;
  String name;

  String avatar;
  String description;

  //创建的歌单
  PlaylistSet createPlaylist;
  //收藏的歌单
  PlaylistSet collectPlaylist;
}