import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:netease_music_cipher/netease_music_cipher.dart';
import 'package:second_music/common/date.dart';
import 'package:second_music/common/json.dart';
import 'package:second_music/entity/search.dart';
import 'package:second_music/entity/song.dart';
import 'package:second_music/entity/song_list.dart';
import 'package:second_music/entity/user.dart';
import 'package:second_music/repository/remote/http_maker.dart';
import 'package:second_music/repository/remote/platform/music_provider.dart';

import '../../../entity/album.dart';
import '../../../entity/enum.dart';
import '../../../entity/playlist.dart';
import '../../../entity/playlist_set.dart';
import '../../../entity/singer.dart';

class NeteaseMusic extends BaseMusicProvider {
  NeteaseMusic(HttpMaker httpMaker) : super(httpMaker);

  @override
  Future<PlaylistSet> showPlayList(
      {int offset = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    String targetUrl =
        'http://music.163.com/discover/playlist/?order=hot&limit=$count&offset=$offset';

    final response = await httpMaker({
      HttpMakerParams.url: targetUrl,
      HttpMakerParams.method: HttpMakerParams.methodGet,
    });
    return await asyncParseHtmlToObject(_DataObjectTags.playlistSet, response);
  }

  @override
  Future<Playlist> playList(String listId,
      {int offset = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    final url = "http://music.163.com/weapi/v3/playlist/detail";
    final params = {
      'id': listId,
      'offset': 0,
      'total': true,
      'limit': 1000,
      'n': 1000,
      'csrf_token': ''
    };

    final respStr = await _neteaseHttpRequest(url, params);

    final respMap = json.decode(respStr);

    final playlistMap = Json.getMap(respMap, 'playlist');
    final trackIds = Json.getList(playlistMap, 'trackIds')
        .map((e) => Json.getObject(e, 'id'))
        .toList();
    final songs = await _parseSongListTracks(trackIds);

    final playlist = _convertPlaylistWithoutSongs(playlistMap);
    playlist.songTotal = songs.length;
    playlist.songs = songs;

    return playlist;
  }

  @override
  Future<Singer> singer(String artistId, MusicObjectType type,
      {int offset = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    return Singer();
  }

  @override
  Future<Album> album(String albumId,
      {int offset = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    final url = 'http://music.163.com/api/album/$albumId';
    final respStr = await httpMaker({
      HttpMakerParams.url: url,
      HttpMakerParams.method: HttpMakerParams.methodGet
    });
    final respMap = json.decode(respStr);

    return _convertAlbum(Json.getMap(respMap, 'album'));
  }

  @override
  bool get searchEnabled => true;

  Future<SearchResult> searchSongs(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) {
    return _searchInternal(1, keyword, page: page, count: count);
  }

  Future<SearchResult> searchPlaylists(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) {
    return _searchInternal(1000, keyword, page: page, count: count);
  }

  Future<SearchResult> searchAlbums(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) {
    return _searchInternal(10, keyword, page: page, count: count);
  }

  Future<SearchResult> searchSingers(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) {
    return _searchInternal(100, keyword, page: page, count: count);
  }

  Future<SearchResult> _searchInternal(int type, String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    final url = 'https://music.163.com/weapi/cloudsearch/get/web';
    final params = {
      'csrf_token': '',
      'hlposttag': '</span>',
      'hlpretag': '<span class="s-fc7">',
      'limit': '$count',
      'offset': (30 * (page - 1)).toString(),
      's': keyword,
      'total': 'false',
      'type': type.toString(),
    };
    final respStr = await _neteaseHttpRequest(url, params);
    final respMap = json.decode(respStr);
    final resultMap = Json.getMap(respMap, 'result');
    return _convertSearchResult(resultMap);
  }

  @override
  Future<bool> parseTrack(Song song) async {
    const url =
        'http://music.163.com/weapi/song/enhance/player/url/v1?csrf_token=';
    final params = {
      'ids': [song.pltId],
      'level': "standard",
      'encodeType': "aac",
      'csrf_token': ""
    };
    final respStr = await _neteaseHttpRequest(url, params);
    final respMap = json.decode(respStr);
    final dataList = Json.getList(respMap, 'data');
    final firstTrackMap = dataList.isNotEmpty ? dataList[0] : null;
    song.streamUrl = Json.getString(firstTrackMap, 'url');
    return true;
  }

  @override
  Future<String> lyric(String songId) async {
    return "";
  }

  @override
  String playlistSource(String playlistId) =>
      'http://music.163.com/#/playlist?id=$playlistId';

  @override
  bool get showPlayListEnabled => true;

  @override
  String singerSource(String singerId) =>
      'http://music.163.com/#/artist/?id=$singerId';

  @override
  String albumSource(String albumId) =>
      'http://music.163.com/#/album?id=$albumId';

  @override
  String songSource(String songId) => 'http://music.163.com/#/song?id=$songId';

  @override
  String userSource(String userId) =>
      'https://music.163.com/#/user/home?id=$userId';

  @override
  MusicPlatform get platform => MusicPlatform.netease;

  Future _neteaseHttpRequest(String url, Map params) async {
    final data = await NeteaseMusicCipher.encrypt(json.encode(params));
    final body =
        'encSecKey=${Uri.encodeQueryComponent(data['encSecKey'])}&params=${Uri.encodeQueryComponent(data['params'])}';
    return await httpMaker({
      HttpMakerParams.url: url,
      HttpMakerParams.method: HttpMakerParams.methodPost,
      HttpMakerParams.data: body,
      HttpMakerParams.headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      }
    });
  }

  Future<List<Song>> _parseSongListTracks(List trackIds) async {
    const url = 'https://music.163.com/weapi/v3/song/detail';
    final params = {
      'c': '[' + trackIds.map((e) => '{"id":$e}').toList().join(',') + ']',
      'ids': '[' + trackIds.join(',') + ']',
    };
    final respStr = await _neteaseHttpRequest(url, params);
    final respMap = json.decode(respStr);
    List songsMap = respMap['songs'];
    return await Future.wait(songsMap.map((e) => _convertSong(e)));
  }

  Playlist _convertPlaylistWithoutSongs(Map<String, dynamic> map) {
    final playlist = Playlist()
      ..plt = MusicPlatform.netease
      ..source = playlistSource(Json.getString(map, 'id'))
      ..id = Json.getString(map, 'id')
      ..cover = Json.getString(map, 'coverImgUrl')
      ..title = Json.getString(map, 'name')
      ..playCount = Json.getInt(map, 'playCount')
      ..favorCount = Json.getInt(map, 'subscribedCount')
      ..description = Json.getString(map, 'description')
      ..type = SongListType.playlist
      ..creator = _convertCreator(Json.getMap(map, 'creator'))
      ..songTotal = Json.getInt(map, 'trackCount');
    return playlist;
  }

  User _convertCreator(Map<String, dynamic> map) {
    final creator = User()
      ..plt = MusicPlatform.netease
      ..source = userSource(map['userId'].toString())
      ..id = map['userId'].toString()
      ..name = map['nickname']
      ..avatar = map['avatarUrl'] ?? ""
      ..description = map['signature'] ?? "";

    return creator;
  }

  Future<Song> _convertSong(Map<String, dynamic> map) async {
    final song = Song()
      ..plt = MusicPlatform.netease
      ..pltId = Json.getString(map, 'id')
      ..name = Json.getString(map, 'name')
      ..subtitle = Json.getList(map, 'alia').join(' | ')
      ..cover = Json.getString(Json.getMap(map, 'al'), 'picUrl')
      ..album = await _convertAlbum(Json.getMap(map, 'al'))
      ..singers = Json.getList(map, 'ar')
          .map<Singer>((e) => _convertSinger(e))
          .toList();
    await parseTrack(song);
    return song;
  }

  Future<Song> _convertSong2(Map<String, dynamic> map) async {
    final song = Song()
      ..plt = MusicPlatform.netease
      ..pltId = Json.getString(map, 'id')
      ..name = Json.getString(map, 'name')
      ..subtitle = Json.getList(map, 'alia').join(' | ')
      ..cover = Json.getString(Json.getMap(map, 'album'), 'picUrl')
      ..album = await _convertAlbum(Json.getMap(map, 'album'))
      ..singers = Json.getList(map, 'artists')
          .map<Singer>((e) => _convertSinger(e))
          .toList();
    await parseTrack(song);
    return song;
  }

  Singer _convertSinger(Map<String, dynamic> map) {
    final singer = Singer()
      ..plt = MusicPlatform.netease
      ..source = singerSource(Json.getString(map, 'id'))
      ..id = Json.getString(map, 'id')
      ..name = Json.getString(map, 'name')
      ..avatar = Json.getString(map, 'picUrl');
    return singer;
  }

  Future<Album> _convertAlbum(Map<String, dynamic> map) async {
    final singers = Json.getList(map, 'artists')
        .map<Singer>((e) => _convertSinger(e))
        .toList();
    final songs = await Future.wait(
        Json.getList(map, 'songs').map((e) => _convertSong2(e)));

    final alias = Json.getList(map, 'alias');
    final album = Album()
      ..plt = MusicPlatform.netease
      ..source = albumSource(Json.getString(map, 'id'))
      ..id = Json.getString(map, 'id')
      ..name = Json.getString(map, 'name')
      ..subtitle = alias.isNotEmpty ? alias[0] : ""
      ..cover = Json.getString(map, 'picUrl')
      ..releaseTime = dateTimeToString(DateTime.fromMillisecondsSinceEpoch(
          Json.getInt(map, 'publishTime') * 1000))
      ..description = Json.getString(map, 'description')
      ..favorCount = Json.getInt(map, 'likedCount')
      ..singers = singers
      ..songTotal = Json.getInt(map, 'size')
      ..songs = songs;
    return album;
  }

  SearchResult _convertSearchResult(Map<String, dynamic> map) {
    final searchResult = SearchResult();

    if (map.containsKey('songs')) {
      searchResult.total = Json.getInt(map, 'songCount');
      searchResult.items =
          Json.getList(map, 'songs').map((e) => _convertSong(e)).toList();
      return searchResult;
    }

    if (map.containsKey('playlists')) {
      searchResult.total = Json.getInt(map, 'playlistCount');
      searchResult.items = Json.getList(map, 'playlists')
          .map((e) => _convertPlaylistWithoutSongs(e))
          .toList();
      return searchResult;
    }

    if (map.containsKey('albums')) {
      searchResult.total = Json.getInt(map, 'albumCount');
      searchResult.items =
          Json.getList(map, 'albums').map((e) => _convertAlbum(e)).toList();
      return searchResult;
    }

    if (map.containsKey('artists')) {
      searchResult.total = Json.getInt(map, 'artistCount');
      searchResult.items =
          Json.getList(map, 'artists').map((e) => _convertSinger(e)).toList();
      return searchResult;
    }

    return searchResult;
  }
}

class _DataObjectTags {
  static const playlistSet = 'playlist_set';
}

Future<dynamic> asyncParseHtmlToObject(String objTag, String html) async {
  final initPort = ReceivePort();
  await Isolate.spawn(_parseHtmlEntryPoint, initPort.sendPort);
  SendPort sendPort = await initPort.first;

  final parsePort = ReceivePort();
  sendPort.send([objTag, html, parsePort.sendPort]);
  final objMap = await parsePort.first;
  switch (objTag) {
    case _DataObjectTags.playlistSet:
      return _syncMapToObjOfPlaylistSet(objMap);
  }
}

PlaylistSet _syncMapToObjOfPlaylistSet(Map<String, dynamic> objMap) {
  final playlistList = objMap['playlists'] as List;
  final playlists = playlistList.map<Playlist>((item) {
    final playlist = Playlist()
      ..id = item['id']
      ..title = item['title']
      ..cover = item['cover']
      ..plt = item['plt']
      ..source = item['source']
      ..playCount = item['playCount'];

    return playlist;
  }).toList();

  final set = PlaylistSet();
  set.hasNext = objMap['hasNext'];
  set.playlists = playlists;
  return set;
}

void _parseHtmlEntryPoint(SendPort initSendPort) async {
  final receivePort = ReceivePort();
  initSendPort.send(receivePort.sendPort);
  await for (final msg in receivePort) {
    final tag = msg[0] as String;
    final html = msg[1] as String;
    final sendPort = msg[2] as SendPort;

    final dom = parse(html);
    var result;
    switch (tag) {
      case _DataObjectTags.playlistSet:
        result = _syncParseDomToMapOfPlaylistSet(dom);
    }

    sendPort.send(result);
  }
}

Map<String, dynamic> _syncParseDomToMapOfPlaylistSet(Document dom) {
  final playlists = <Map<String, dynamic>>[];
  dom.querySelectorAll('.m-cvrlst li').forEach((Element ele) {
    final item = <String, dynamic>{};
    String? url = ele.querySelector('div a')?.attributes['href'] ?? "";
    item['id'] = Uri.parse(url).queryParameters['id'];
    item['title'] =
        ele.querySelector('div a')?.attributes['title']?.trim() ?? "";
    item['cover'] = ele.querySelector('img')?.attributes['src'] ?? "";
    item['plt'] = MusicPlatform.netease;
    item['source'] = 'http://music.163.com/#/playlist?id=' + item['id'];
    final countStr = ele.querySelector('.nb')?.text;
    item['playCount'] =
        countStr.isNullOrEmpty() ? 0 : _playCountFromText(countStr!) ?? 0;
    playlists.add(item);
  });

  final set = <String, dynamic>{};
  set['hasNext'] = dom.querySelector(".znxt.js-disabled") == null;
  set['playlists'] = playlists;
  return set;
}

int? _playCountFromText(String text) {
  String? numStr = RegExp(r'\d+').stringMatch(text);
  if (numStr == null) {
    return null;
  }
  final num = int.tryParse(numStr);
  if (num != null && text.endsWith('万')) {
    return num * 10000;
  }
  return num;
}