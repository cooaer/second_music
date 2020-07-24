import 'dart:async';

import 'package:second_music/model/album.dart';
import 'package:second_music/model/enum.dart';
import 'package:second_music/model/playlist.dart';
import 'package:second_music/model/playlist_set.dart';
import 'package:second_music/model/search.dart';
import 'package:second_music/model/singer.dart';
import 'package:second_music/model/song.dart';
import 'package:second_music/model/song_list.dart';
import 'package:second_music/network/http_maker.dart';
import 'package:second_music/network/platform/netease_music.dart';
import 'package:second_music/network/platform/qq_music.dart';
import 'package:second_music/network/platform/xiami_music.dart';

typedef void Completion<T>(int code, String msg, T data);

const int DEFAULT_REQUEST_COUNT = 30;

abstract class MusicProvider {
  static final _instances = Map<String, MusicProvider>();

  factory MusicProvider(String plt) {
    if (_instances.containsKey(plt)) {
      return _instances[plt];
    }
    MusicProvider instance;
    switch (plt) {
      case MusicPlatforms.NETEASE:
        instance = NeteaseMusic(dioHttpMaker);
        break;
      case MusicPlatforms.QQ:
        instance = QQMusic(dioHttpMaker);
        break;
      case MusicPlatforms.XIAMI:
        instance = XiamiMusic(dioHttpMaker);
        break;
    }
    _instances[plt] = instance;
    return instance;
  }

  ///主页精选的歌单（简略信息）
  Future<PlaylistSet> showPlayList({int offset = 0, int count = DEFAULT_REQUEST_COUNT});

  ///获取歌单的详情
  Future<Playlist> playList(String listId, {int offset = 0, int count = DEFAULT_REQUEST_COUNT});

  ///获取歌手详情，包含歌曲和专辑
  Future<Singer> singer(String artistId, MusicObjectType type,
      {int offset = 0, int count = DEFAULT_REQUEST_COUNT});

  ///获取专辑详情，包含所有歌曲
  Future<Album> album(String albumId, {int offset, int count = DEFAULT_REQUEST_COUNT});

  ///搜索歌曲、歌单、专辑
  Future<SearchResult> search(String text, MusicObjectType type,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT});

  Future<SearchResult> searchSongs(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT});

  Future<SearchResult> searchPlaylists(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT});

  Future<SearchResult> searchAlbums(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT});

  Future<SearchResult> searchSingers(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT});

  ///获取音乐流地址
  Future<bool> parseTrack(Song song);

  ///获取歌曲的歌词
  Future<String> lyric(String songId);

  Future<SongList> songList(SongListType type, String songListId,
      {int offset = 0, int count = DEFAULT_REQUEST_COUNT});

  String playlistSource(String playlistId);

  String singerSource(String singerId);

  String albumSource(String albumId);

  String songSource(String songId);

  String userSource(String userId);

  String songListSource(SongListType type, String songListId);

  String songListUserSource(SongListType type, String songListId);

  bool get showPlayListEnabled;

  bool get searchEnabled;

  String get platform;
}

abstract class BaseMusicProvider implements MusicProvider {
  final HttpMaker httpMaker;

  BaseMusicProvider(this.httpMaker);

  @override
  Future<PlaylistSet> showPlayList({int offset = 0, int count = DEFAULT_REQUEST_COUNT}) {
    return null;
  }

  //查询本地某个歌单的所有的歌曲
  @override
  Future<Playlist> playList(String listId, {int offset = 0, int count = DEFAULT_REQUEST_COUNT}) {
    return null;
  }

  @override
  Future<SearchResult> search(String keyword, MusicObjectType type,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    if (type == MusicObjectType.song) {
      return searchSongs(keyword, page: page, count: count);
    } else if (type == MusicObjectType.playlist) {
      return searchPlaylists(keyword, page: page, count: count);
    } else if (type == MusicObjectType.album) {
      return searchAlbums(keyword, page: page, count: count);
    } else if (type == MusicObjectType.singer) {
      return searchSingers(keyword, page: page, count: count);
    }
    return Future.value(null);
  }

  Future<SearchResult> searchSongs(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) {
    return null;
  }

  Future<SearchResult> searchPlaylists(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) {
    return null;
  }

  Future<SearchResult> searchAlbums(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) {
    return null;
  }

  Future<SearchResult> searchSingers(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) {
    return null;
  }

  @override
  Future<Singer> singer(String artistId, MusicObjectType type,
      {int offset = 0, int count = DEFAULT_REQUEST_COUNT}) {
    return null;
  }

  @override
  Future<Album> album(String albumId, {int offset, int count = DEFAULT_REQUEST_COUNT}) {
    return null;
  }

  @override
  Future<String> lyric(String songId) {
    return null;
  }

  @override
  Future<bool> parseTrack(Song song) {
    return null;
  }

  Future<SongList> songList(SongListType type, String songListId,
      {int offset = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    if (type == SongListType.album) {
      var data = await album(songListId, offset: offset, count: count);
      return SongList.fromAlbum(data);
    } else if (type == SongListType.playlist) {
      var data = await playList(songListId, offset: offset, count: count);
      return SongList.fromPlaylist(data);
    }
    return null;
  }

  @override
  String albumSource(String albumId) {
    return null;
  }

  @override
  String playlistSource(String playlistId) {
    return null;
  }

  @override
  String singerSource(String singerId) {
    return null;
  }

  @override
  String songSource(String songId) {
    return null;
  }

  @override
  String userSource(String userId) {
    return null;
  }

  String songListSource(SongListType type, String songListId) {
    if (type == SongListType.album) {
      return albumSource(songListId);
    } else if (type == SongListType.playlist) {
      return playlistSource(songListId);
    }
    return null;
  }

  @override
  String songListUserSource(SongListType type, String songListId) {
    if (type == SongListType.album) {
      return singerSource(songListId);
    } else if (type == SongListType.playlist) {
      return userSource(songListId);
    }
    return null;
  }

  @override
  bool get showPlayListEnabled => false;

  @override
  bool get searchEnabled => false;
}
