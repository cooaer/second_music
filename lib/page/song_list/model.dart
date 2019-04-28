import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:second_music/common/palette.dart';
import 'package:second_music/model/album.dart';
import 'package:second_music/model/enum.dart';
import 'package:second_music/model/playlist.dart';
import 'package:second_music/model/song.dart';
import 'package:second_music/model/song_list.dart';
import 'package:second_music/network/platform/music_provider.dart';
import 'package:second_music/page/home/my_song_list/model.dart';
import 'package:second_music/storage/database/music/dao.dart';

class SongListModel {
  final String plt;
  final String songListId;
  final SongListType songListType;

  var _mySongListDao = MySongListDao();

  SongListModel(this.plt, this.songListId, this.songListType);

  SongList _songList;
  var _songListStreamController = StreamController<SongList>.broadcast();
  Stream<SongList> get songListStream => _songListStreamController.stream;

  void refresh() async{
    await _refreshCollectionState();
    await _refreshSongList();
  }

  /// 更新列表数据，自己创建或收藏的歌单：读取本地数据，平台的歌单或专辑：通过网络读取
  Future _refreshSongList() async {
    if(_isCollected){
      _songList = await _mySongListDao.querySongList(plt, songListId, songListType);
      _songListStreamController.add(_songList);
      await Future.delayed(Duration(seconds: 2));
    }
    if(plt != MusicPlatforms.LOCAL){
      _songList = await MusicProvider(plt).songList(songListType, songListId);
      _songListStreamController.add(_songList);
      if(_isCollected){
        // 更新收藏到本地的歌单数据
        _mySongListDao.saveSongList(_songList);
      }
    }
    //更新AppBar颜色
    if(_songList.hasDisplayCover){
      _generateBarColor(_songList.displayCover);
    }
  }

  // 收藏状态
  bool _isCollected;

  bool get isCollected => _isCollected;
  var _isCollectedController = StreamController<bool>.broadcast();

  Stream<bool> get isCollectedStream => _isCollectedController.stream;

  /// 查询收藏状态
  Future _refreshCollectionState() async {
    _isCollected = await _mySongListDao.hasSongList(plt, songListId, songListType);
    _isCollectedController.add(_isCollected);
  }

  /// 收藏歌单，保存歌单到数据库
  Future togglePlaylistCollection() async {
    if (_songList == null || _isCollected == null) return;
    _isCollectedController.add(!_isCollected);
    var result = false;
    if (_isCollected) {
      result = await _mySongListDao.deleteSongList(plt, songListId, songListType);
      _isCollected = false;
    } else {
      result = await _mySongListDao.saveSongList(_songList);
      _isCollected = true;
    }
    if (result) {
      notifyMySongListChanged();
    }
    _isCollectedController.add(_isCollected);
  }

  // AppBar color
  var _barColor = Color(0xff8f8f8f);
  Color get barColor => _barColor;

  var _barColorController = StreamController<Color>.broadcast();
  Stream<Color> get barColorStream => _barColorController.stream;

  PaletteGenerator _paletteGenerator;

  void _generateBarColor(String coverUrl) async{
    _paletteGenerator = await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(coverUrl),
        size: Size(140, 140));
    _barColor = _headerBackgroundColor();
    _barColorController.add(_barColor);
  }

  Color _headerBackgroundColor() {
    var defColor = Color(0xff8f8f8f);
    if (_paletteGenerator == null) return defColor;
    return _paletteGenerator.dominantColor?.color ??
        _paletteGenerator.lightVibrantColor?.color ??
        _paletteGenerator.lightMutedColor?.color ??
        _paletteGenerator.darkVibrantColor?.color ??
        _paletteGenerator.darkMutedColor?.color ??
        defColor;
  }

  /// 编辑歌单，本地歌单：收藏到歌单、下一首播放、删除，平台歌单：没有删除功能
  void dispose() {
    _songListStreamController.close();
    _isCollectedController.close();
    _mySongListDao.close();
  }
}
