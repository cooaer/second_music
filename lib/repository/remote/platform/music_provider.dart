import 'dart:async';

import 'package:second_music/entity/album.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/playlist.dart';
import 'package:second_music/entity/playlist_set.dart';
import 'package:second_music/entity/search.dart';
import 'package:second_music/entity/singer.dart';
import 'package:second_music/entity/song.dart';
import 'package:second_music/entity/song_list.dart';
import 'package:second_music/repository/remote/http_maker.dart';
import 'package:second_music/repository/remote/platform/bilibili_music.dart';
import 'package:second_music/repository/remote/platform/migu_music.dart';
import 'package:second_music/repository/remote/platform/netease_music.dart';
import 'package:second_music/repository/remote/platform/qq_music.dart';

typedef void Completion<T>(int code, String msg, T data);

const int DEFAULT_REQUEST_COUNT = 30;

abstract class MusicProvider {
  static final _instances = <MusicPlatform, MusicProvider>{};

  factory MusicProvider(MusicPlatform plt) {
    if (_instances.containsKey(plt)) {
      return _instances[plt]!;
    }
    final dioHttpMaker = HttpMaker();
    MusicProvider instance;
    switch (plt) {
      case MusicPlatform.netease:
        instance = NeteaseMusic(dioHttpMaker);
        break;
      case MusicPlatform.qq:
        instance = QQMusic(dioHttpMaker);
        break;
      case MusicPlatform.migu:
        instance = MiguMusic(dioHttpMaker);
        break;
      case MusicPlatform.bilibili:
        instance = BilibiliMusic(dioHttpMaker);
        break;
    }
    _instances[plt] = instance;
    return instance;
  }

  ///主页精选的歌单（简略信息）
  Future<PlaylistSet?> showPlayList(
      {int offset = 0, int count = DEFAULT_REQUEST_COUNT});

  ///获取歌单的详情
  Future<Playlist?> playlist(String playlistId);

  ///获取歌手详情，包含歌曲和专辑
  Future<Singer?> singer(String artistId, MusicObjectType type,
      {int offset = 0, int count = DEFAULT_REQUEST_COUNT});

  ///获取专辑详情，包含所有歌曲
  Future<Album?> album(String albumId);

  ///搜索歌曲、歌单、专辑
  Future<SearchResult?> search(String text, MusicObjectType type,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT});

  Future<SearchResult?> searchSong(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT});

  Future<SearchResult?> searchPlaylist(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT});

  Future<SearchResult?> searchAlbum(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT});

  Future<SearchResult?> searchSinger(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT});

  ///获取音乐流地址
  Future<bool> parseSoundUrl(Song song);

  ///获取歌词
  Future<String> lyric(String songId);

  Future<SongList?> songList(SongListType type, String songListId);

  String playlistSource(String playlistId);

  String singerSource(String singerId);

  String albumSource(String albumId);

  String songSource(String songId);

  String userSource(String userId);

  String songListSource(SongListType type, String songListId);

  String songListUserSource(SongListType type, String songListId);

  bool get showPlayListEnabled;

  bool get searchEnabled;

  MusicPlatform get platform;

  Map<String, String>? get playHeaders;
}

abstract class BaseMusicProvider implements MusicProvider {
  final HttpMaker httpMaker;

  BaseMusicProvider(this.httpMaker);

  @override
  Future<SearchResult?> search(String keyword, MusicObjectType type,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    switch (type) {
      case MusicObjectType.song:
        return searchSong(keyword, page: page, count: count);
      case MusicObjectType.playlist:
        return searchPlaylist(keyword, page: page, count: count);
      case MusicObjectType.album:
        return searchAlbum(keyword, page: page, count: count);
      case MusicObjectType.singer:
        return searchSinger(keyword, page: page, count: count);
    }
  }

  Future<SongList?> songList(SongListType type, String songListId) async {
    switch (type) {
      case SongListType.album:
        var data = await album(songListId);
        return data == null ? null : SongList.fromAlbum(data);
      case SongListType.playlist:
        var data = await playlist(songListId);
        return data == null ? null : SongList.fromPlaylist(data);
    }
  }

  String songListSource(SongListType type, String songListId) {
    switch (type) {
      case SongListType.album:
        return albumSource(songListId);
      case SongListType.playlist:
        return playlistSource(songListId);
    }
  }

  @override
  String songListUserSource(SongListType type, String songListId) {
    switch (type) {
      case SongListType.album:
        return singerSource(songListId);
      case SongListType.playlist:
        return userSource(songListId);
    }
  }

  @override
  bool get showPlayListEnabled => false;

  @override
  bool get searchEnabled => false;

  @override
  Map<String, String>? get playHeaders => null;
}
