import 'dart:convert';

import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:flutter/material.dart';
import 'package:second_music/common/json.dart';
import 'package:second_music/entity/album.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/playlist.dart';
import 'package:second_music/entity/playlist_set.dart';
import 'package:second_music/entity/search.dart';
import 'package:second_music/entity/singer.dart';
import 'package:second_music/entity/song.dart';
import 'package:second_music/entity/user.dart';
import 'package:second_music/repository/remote/http_maker.dart';
import 'package:second_music/repository/remote/platform/music_provider.dart';

class BilibiliMusic extends BaseMusicProvider {
  static const _playHeaders = {
    "referer": "https://www.bilibili.com/",
    "user-agent":
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36",
  };

  BilibiliMusic(HttpMaker httpMaker) : super(httpMaker);

  @override
  Future<Album?> album(String albumId,
      {int offset = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    return null;
  }

  @override
  String albumSource(String albumId) {
    return "";
  }

  @override
  Future<String> lyric(String songId) async {
    return '';
  }

  @override
  Future<bool> parseSoundUrl(Song song) async {
    final soundUrl = song.pltId.startsWith('BV')
        ? await _parseBvSoundUrl(song.pltId)
        : await _parseSoundUrl(song.pltId);
    if (soundUrl != null) {
      song.soundUrl = soundUrl;
    }
    debugPrint('bili.parseSoundUrl, soundUrl = $soundUrl');
    return soundUrl != null;
  }

  Future<String?> _parseSoundUrl(String songId) async {
    final targetUrl =
        'https://www.bilibili.com/audio/music-service-c/web/url?sid=$songId';
    final httpResp = await httpMaker.get(targetUrl);
    final respJson = jsonDecode(httpResp) as Map<String, dynamic>;
    final dataJson = respJson.getMap('data');
    final cdnsJson = dataJson.getList('cdns');
    return cdnsJson.firstOrNull;
  }

  Future<String?> _parseBvSoundUrl(String bvid) async {
    final targetUrl =
        'https://api.bilibili.com/x/web-interface/view?bvid=$bvid';
    final httpResp = await httpMaker.get(targetUrl);
    final respJson = jsonDecode(httpResp) as Map<String, dynamic>;
    final dataJson = respJson.getMap('data');
    final pagesJson = dataJson.getList('pages');
    final firstPageJson = pagesJson.getMap(0);
    final cid = firstPageJson.getInt('cid');

    final targetUrl2 =
        'http://api.bilibili.com/x/player/playurl?fnval=16&bvid=${bvid}&cid=${cid}';
    final httpResp2 = await httpMaker.get(targetUrl2);
    final respJson2 = jsonDecode(httpResp2) as Map<String, dynamic>;
    final dataJson2 = respJson2.getMap('data');
    final dashJson = dataJson2.getMap('dash');
    final audioJson = dashJson.getList('audio');
    if (audioJson.length > 0) {
      return audioJson[0]['baseUrl'];
    }
    return null;
  }

  @override
  MusicPlatform get platform => MusicPlatform.bilibili;

  @override
  Future<Playlist?> playlist(String playlistId) async {
    final infoUrl =
        'https://www.bilibili.com/audio/music-service-c/web/menu/info?sid=$playlistId';
    final infoResp = await httpMaker.get(infoUrl);
    if (infoResp.isEmpty) {
      return null;
    }
    final infoRespJson = jsonDecode(infoResp) as Map<String, dynamic>;
    final infoDataJson = infoRespJson.getMap("data");
    final playlist = _convertPlaylist(infoDataJson);

    var page = 1;
    final count = 100;
    var totalSize = 0;
    final allSongs = <Song>[];
    while (true) {
      final songsUrl =
          'https://www.bilibili.com/audio/music-service-c/web/song/of-menu?pn=$page&ps=$count&sid=$playlistId';
      final songsResp = await httpMaker.get(songsUrl);
      final songsRespJson = jsonDecode(songsResp) as Map<String, dynamic>;
      final songsDataJson = songsRespJson.getMap('data');
      totalSize = songsDataJson.getInt('totalSize');
      final songsDataDataJson = songsDataJson.getList('data');
      final songs = songsDataDataJson.map((e) => _convertSong(e)).toList();
      allSongs.addAll(songs);
      if (page * count >= totalSize) {
        break;
      }
      page++;
    }
    return playlist
      ..songTotal = totalSize
      ..songs = allSongs;
  }

  Song _convertSong(Map<String, dynamic> songJson) {
    final singer = Singer()
      ..plt = MusicPlatform.bilibili
      ..pltId = songJson.getString('uid')
      ..name = songJson.getString('uname');

    return Song()
      ..plt = MusicPlatform.bilibili
      ..pltId = songJson.getString('id')
      ..name = songJson.getString('title')
      ..cover = songJson.getString('cover')
      ..description = songJson.getString('intro')
      ..lyricUrl = songJson.getString('lyric')
      ..singer = singer;
  }

  @override
  String playlistSource(String playlistId) {
    return 'https://www.bilibili.com/audio/am$playlistId';
  }

  @override
  Future<SearchResult?> searchAlbum(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    return null;
  }

  @override
  Future<SearchResult?> searchPlaylist(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    return null;
  }

  @override
  Future<SearchResult?> searchSinger(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    return null;
  }

  @override
  Future<SearchResult?> searchSong(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    final encodedKeyword = Uri.encodeComponent(keyword);
    final targetUrl = 'https://api.bilibili.com/x/web-interface/search/type?'
        '__refresh__=true&_extra=&context=&page=${page + 1}&page_size=42'
        '&platform=pc&highlight=1&single_column=0&keyword=$encodedKeyword'
        '&category_id=&search_type=video&dynamic_offset=0&preload=true&com2co=true';
    final httpResp = await httpMaker.get(targetUrl);
    if (httpResp.isEmpty) {
      return null;
    }
    final respJson = jsonDecode(httpResp) as Map<String, dynamic>;
    final dataJson = respJson.getMap('data');
    final totalCount = dataJson.getInt('numResults');
    final dataDataJson = dataJson.getList('result');
    final songs = dataDataJson.map((e) => _convertSong2(e)).toList();

    return SearchResult()
      ..total = totalCount
      ..items = songs;
  }

  Song _convertSong2(Map<String, dynamic> songJson) {
    final songPic = songJson.getString('pic');
    final songName = songJson.getString('title');

    final singer = Singer()
      ..plt = MusicPlatform.bilibili
      ..pltId = songJson.getString('mid')
      ..name = songJson.getString('author')
      ..avatar = songJson.getString('upic');

    return Song()
      ..plt = MusicPlatform.bilibili
      ..pltId = songJson.getString('bvid')
      ..name = songName
          .replaceAll('<em class=\"keyword\">', '')
          .replaceAll('</em>', '')
      ..cover = songPic.startsWith("//") ? "https:$songPic" : songPic
      ..description = songJson.getString('description')
      ..isPlayable = songJson.getInt('is_pay') == 0
      ..singer = singer;
  }

  @override
  Future<PlaylistSet?> showPlayList(
      {int offset = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    //page 从 1 开始
    final page = (offset / count).ceil() + 1;
    final targetUrl =
        'https://www.bilibili.com/audio/music-service-c/web/menu/hit?ps=$count&pn=$page';
    final httpResp = await httpMaker.get(targetUrl);
    if (httpResp.isEmpty) {
      return null;
    }
    final respJson = jsonDecode(httpResp) as Map<String, dynamic>;
    final dataJson = respJson.getMap("data");
    final dataDataJson = dataJson.getList('data');
    final pageCount = dataJson.getInt('pageCount');

    final playlists = dataDataJson
        .map((playlistJson) => _convertPlaylist(playlistJson))
        .toList();
    return PlaylistSet()
      ..hasNext = pageCount - 1 > page
      ..playlists = playlists;
  }

  Playlist _convertPlaylist(Map<String, dynamic> playlistJson) {
    final statJson = playlistJson.getMap('statistic');

    final creator = User()
      ..plt = MusicPlatform.bilibili
      ..pltId = playlistJson.getString('uid')
      ..name = playlistJson.getString('uname');

    return Playlist()
      ..plt = MusicPlatform.bilibili
      ..pltId = playlistJson.getString('menuId')
      ..title = playlistJson.getString('title')
      ..cover = playlistJson.getString('cover')
      ..description = playlistJson.getString('intro')
      ..playCount = statJson.getInt('play')
      ..favorCount = statJson.getInt('collect')
      ..creator = creator;
  }

  @override
  Future<Singer?> singer(String artistId, MusicObjectType type,
      {int offset = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    return null;
  }

  @override
  String singerSource(String singerId) {
    return 'https://space.bilibili.com/$singerId';
  }

  @override
  String songSource(String songId) {
    return songId.startsWith('BV')
        ? 'https://www.bilibili.com/$songId'
        : 'https://www.bilibili.com/audio/au$songId';
  }

  @override
  String userSource(String userId) {
    return 'https://space.bilibili.com/$userId';
  }

  @override
  Map<String, String>? get playHeaders => _playHeaders;
}
