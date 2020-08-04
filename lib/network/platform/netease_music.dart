import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:netease_music_cipher/netease_music_cipher.dart';
import 'package:second_music/common/date.dart';
import 'package:second_music/common/json.dart';
import 'package:second_music/model/search.dart';
import 'package:second_music/model/song.dart';
import 'package:second_music/model/song_list.dart';
import 'package:second_music/model/user.dart';
import 'package:second_music/network/http_maker.dart';
import 'package:second_music/network/platform/music_provider.dart';

import '../../model/album.dart';
import '../../model/enum.dart';
import '../../model/playlist.dart';
import '../../model/playlist_set.dart';
import '../../model/singer.dart';

class NeteaseMusic extends BaseMusicProvider {
  NeteaseMusic(HttpMaker httpMaker) : super(httpMaker);

  @override
  Future<PlaylistSet> showPlayList({int offset = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    String targetUrl =
        'http://music.163.com/discover/playlist/?order=hot&limit=$count&offset=$offset';

    var response = await httpMaker({
      HttpMakerParams.url: targetUrl,
      HttpMakerParams.method: HttpMakerParams.methodGet,
    });
    return await asyncParseHtmlToObject(_DataObjectTags.playlistSet, response);
  }

  @override
  Future<Playlist> playList(String listId,
      {int offset = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    var url = "http://music.163.com/weapi/v3/playlist/detail";
    var params = {
      'id': listId,
      'offset': 0,
      'total': true,
      'limit': 1000,
      'n': 1000,
      'csrf_token': ''
    };

    var respStr = await _neteaseHttpRequest(url, params);

    var respMap = json.decode(respStr);

    var playlistMap = Json.getMap(respMap, 'playlist');
    var trackIds =
        Json.getList(playlistMap, 'trackIds').map((e) => Json.getObject(e, 'id')).toList();
    var songs = await _parseSongListTracks(trackIds);

    var playlist = _convertPlaylistWithoutSongs(playlistMap);
    playlist.songTotal = songs?.length;
    playlist.songs = songs;

    return playlist;
  }

  @override
  Future<Singer> singer(String artistId, MusicObjectType type,
      {int offset = 0, int count = DEFAULT_REQUEST_COUNT}) {
    // TODO: implement artist
    return null;
  }

  @override
  Future<Album> album(String albumId, {int offset, int count = DEFAULT_REQUEST_COUNT}) async {
    var url = 'http://music.163.com/api/album/$albumId';
    var respStr = await httpMaker(
        {HttpMakerParams.url: url, HttpMakerParams.method: HttpMakerParams.methodGet});
    var respMap = json.decode(respStr);

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
    var url = 'https://music.163.com/weapi/cloudsearch/get/web';
    var params = {
      'csrf_token': '',
      'hlposttag': '</span>',
      'hlpretag': '<span class="s-fc7">',
      'limit': '$count',
      'offset': (30 * (page - 1)).toString(),
      's': keyword,
      'total': 'false',
      'type': type.toString(),
    };
    var respStr = await _neteaseHttpRequest(url, params);
    var respMap = json.decode(respStr);
    var resultMap = Json.getMap(respMap, 'result');
    return _convertSearchResult(resultMap);
  }

  @override
  Future<bool> parseTrack(Song song) async {
    const url = 'http://music.163.com/weapi/song/enhance/player/url/v1?csrf_token=';
    var params = {
      'ids': [song.id],
      'level': "standard",
      'encodeType': "aac",
      'csrf_token': ""
    };
    var respStr = await _neteaseHttpRequest(url, params);
    var respMap = json.decode(respStr);
    var dataList = Json.getList(respMap, 'data');
    var firstTrackMap = dataList != null && dataList.isNotEmpty ? dataList[0] : null;
    song.streamUrl = Json.getString(firstTrackMap, 'url');
    return true;
  }

  @override
  Future<String> lyric(String songId) {
    // TODO: implement lyric
    return null;
  }

  @override
  String playlistSource(String playlistId) => 'http://music.163.com/#/playlist?id=$playlistId';

  @override
  bool get showPlayListEnabled => true;

  @override
  String singerSource(String singerId) => 'http://music.163.com/#/artist/?id=$singerId';

  @override
  String albumSource(String albumId) => 'http://music.163.com/#/album?id=$albumId';

  @override
  String songSource(String songId) => 'http://music.163.com/#/song?id=$songId';

  @override
  String userSource(String userId) => 'https://music.163.com/#/user/home?id=$userId';

  @override
  String get platform => MusicPlatforms.NETEASE;

  Future _neteaseHttpRequest(String url, Map params) async {
    var data = await NeteaseMusicCipher.encrypt(json.encode(params));
    var body =
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
    var params = {
      'c': '[' + trackIds.map((e) => '{"id":$e}').toList().join(',') + ']',
      'ids': '[' + trackIds.join(',') + ']',
    };
    var respStr = await _neteaseHttpRequest(url, params);
    var respMap = json.decode(respStr);
    List songsMap = respMap['songs'];
    return songsMap.map<Song>((e) => _convertSong(e)).toList();
  }

  Playlist _convertPlaylistWithoutSongs(Map map) {
    var playlist = Playlist()
      ..plt = MusicPlatforms.NETEASE
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

  User _convertCreator(Map map) {
    if (map == null) {
      return null;
    }
    var creator = User()
      ..plt = MusicPlatforms.NETEASE
      ..source = userSource(map['userId'].toString())
      ..id = map['userId'].toString()
      ..name = map['nickname']
      ..avatar = map['avatarUrl']
      ..description = map['signature'];

    return creator;
  }

  Song _convertSong(Map map) {
    if (map == null) {
      return null;
    }
    var song = Song()
      ..plt = MusicPlatforms.NETEASE
      ..id = Json.getString(map, 'id')
      ..name = Json.getString(map, 'name')
      ..subtitle = Json.getList(map, 'alia').join(' | ')
      ..cover = Json.getString(Json.getMap(map, 'al'), 'picUrl')
      ..album = _convertAlbum(Json.getMap(map, 'al'))
      ..singers = Json.getList(map, 'ar')?.map<Singer>((e) => _convertSinger(e))?.toList();
    //alia
    return song;
  }

  Song _convertSong2(Map map) {
    if (map == null) {
      return null;
    }
    var song = Song()
      ..plt = MusicPlatforms.NETEASE
      ..id = Json.getString(map, 'id')
      ..name = Json.getString(map, 'name')
      ..subtitle = Json.getList(map, 'alia').join(' | ')
      ..cover = Json.getString(Json.getMap(map, 'album'), 'picUrl')
      ..album = _convertAlbum(Json.getMap(map, 'album'))
      ..singers = Json.getList(map, 'artists')?.map<Singer>((e) => _convertSinger(e))?.toList();
    return song;
  }

  Singer _convertSinger(Map map) {
    if (map == null) {
      return null;
    }
    var singer = Singer()
      ..plt = MusicPlatforms.NETEASE
      ..source = singerSource(Json.getString(map, 'id'))
      ..id = Json.getString(map, 'id')
      ..name = Json.getString(map, 'name')
      ..avatar = Json.getString(map, 'picUrl');
    return singer;
  }

  Album _convertAlbum(Map map) {
    if (map == null) {
      return null;
    }

    var singers = Json.getList(map, 'artists')?.map<Singer>((e) => _convertSinger(e))?.toList();
    var songs = Json.getList(map, 'songs')?.map((e) => _convertSong2(e))?.toList();

    var alias = Json.getList(map, 'alias');
    var album = Album()
      ..plt = MusicPlatforms.NETEASE
      ..source = albumSource(Json.getString(map, 'id'))
      ..id = Json.getString(map, 'id')
      ..name = Json.getString(map, 'name')
      ..subtitle = alias != null && alias.isNotEmpty ? alias[0] : null
      ..cover = Json.getString(map, 'picUrl')
      ..releaseTime = dateTimeToString(
          DateTime.fromMillisecondsSinceEpoch(Json.getInt(map, 'publishTime') * 1000))
      ..description = Json.getString(map, 'description')
      ..favorCount = Json.getInt(map, 'likedCount')
      ..singers = singers
      ..songTotal = Json.getInt(map, 'size')
      ..songs = songs;
    return album;
  }

  SearchResult _convertSearchResult(Map map) {
    if (map == null) {
      return null;
    }

    var searchResult = SearchResult();

    if (map.containsKey('songs')) {
      searchResult.total = Json.getInt(map, 'songCount');
      searchResult.items = Json.getList(map, 'songs').map((e) => _convertSong(e)).toList();
      return searchResult;
    }

    if (map.containsKey('playlists')) {
      searchResult.total = Json.getInt(map, 'playlistCount');
      searchResult.items =
          Json.getList(map, 'playlists').map((e) => _convertPlaylistWithoutSongs(e)).toList();
      return searchResult;
    }

    if (map.containsKey('albums')) {
      searchResult.total = Json.getInt(map, 'albumCount');
      searchResult.items = Json.getList(map, 'albums').map((e) => _convertAlbum(e)).toList();
      return searchResult;
    }

    if (map.containsKey('artists')) {
      searchResult.total = Json.getInt(map, 'artistCount');
      searchResult.items = Json.getList(map, 'artists').map((e) => _convertSinger(e)).toList();
      return searchResult;
    }

    return null;
  }
}

class _DataObjectTags {
  static const playlistSet = 'playlist_set';
}

Future<dynamic> asyncParseHtmlToObject(String objTag, String html) async {
  var initPort = ReceivePort();
  await Isolate.spawn(_parseHtmlEntryPoint, initPort.sendPort);
  SendPort sendPort = await initPort.first;

  var parsePort = ReceivePort();
  sendPort.send([objTag, html, parsePort.sendPort]);
  var objMap = await parsePort.first;
  switch (objTag) {
    case _DataObjectTags.playlistSet:
      return _syncMapToObjOfPlaylistSet(objMap);
  }
}

PlaylistSet _syncMapToObjOfPlaylistSet(dynamic objMap) {
  var playlistList = objMap['playlists'] as List;
  var playlists = playlistList?.map<Playlist>((item) {
    var playlist = Playlist()
      ..id = item['id']
      ..title = item['title']
      ..cover = item['cover']
      ..plt = item['plt']
      ..source = item['source']
      ..playCount = item['playCount'];

    return playlist;
  })?.toList();

  var set = PlaylistSet();
  set.hasNext = objMap['hasNext'];
  set.playlists = playlists;
  return set;
}

void _parseHtmlEntryPoint(SendPort initSendPort) async {
  var receivePort = ReceivePort();
  initSendPort.send(receivePort.sendPort);
  await for (var msg in receivePort) {
    var tag = msg[0] as String;
    var html = msg[1] as String;
    var sendPort = msg[2] as SendPort;

    var dom = parse(html);
    var result;
    switch (tag) {
      case _DataObjectTags.playlistSet:
        result = _syncParseDomToMapOfPlaylistSet(dom);
    }

    sendPort.send(result);
  }
}

Map<String, dynamic> _syncParseDomToMapOfPlaylistSet(Document dom) {
  var playlists = <Map<String, dynamic>>[];
  dom.querySelectorAll('.m-cvrlst li').forEach((Element ele) {
    var item = <String, dynamic>{};
    String url = ele.querySelector('div a').attributes['href'];
    item['id'] = Uri.parse(url).queryParameters['id'];
    item['title'] = ele.querySelector('div a').attributes['title'].trim();
    item['cover'] = ele.querySelector('img').attributes['src'];
    item['plt'] = MusicPlatforms.NETEASE;
    item['source'] = 'http://music.163.com/#/playlist?id=' + item['id'];
    item['playCount'] = _playCountFromText(ele.querySelector('.nb').text);
    playlists.add(item);
  });

  var set = <String, dynamic>{};
  set['hasNext'] = dom.querySelector(".znxt.js-disabled") == null;
  set['playlists'] = playlists;
  return set;
}

int _playCountFromText(String text) {
  String num = RegExp(r'\d+').stringMatch(text);
  if (text.endsWith('万')) {
    return int.parse(num) * 10000;
  }
  return int.parse(num);
}
