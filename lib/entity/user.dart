import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/playlist_set.dart';

class User {
  MusicPlatform plt = MusicPlatform.netease;
  String pltId = "";
  String name = "";

  String avatar = "";
  String description = "";
  String source = "";

  //创建的歌单
  PlaylistSet? createPlaylist;
  //收藏的歌单
  PlaylistSet? collectPlaylist;
}
