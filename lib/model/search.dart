import 'package:second_music/model/album.dart';
import 'package:second_music/model/playlist.dart';
import 'package:second_music/model/singer.dart';
import 'package:second_music/model/song.dart';

//搜索结果
class SearchResult
{
  var page = 0;
  var hasError = false;

  int total;
  List items = [];

  bool get hasMore => total == null || items == null ? true : total > items.length;

  int get nextPage => hasError ? page : page + 1;

}