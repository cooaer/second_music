import 'package:second_music/model/album.dart';
import 'package:second_music/model/song.dart';


class Singer
{
  String plt;//歌手来源平台
  String source;//歌手主页
  String id;
  String name;//歌手名称
  String avatar;
  String introduction;//歌手简介

  int songTotal;
  List<Song> songs;//热门歌曲
  int albumTotal;
  List<Album> albums;//专辑
}