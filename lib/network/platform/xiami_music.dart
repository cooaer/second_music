import 'dart:convert';

import 'package:second_music/common/date.dart';
import 'package:second_music/common/json.dart';
import 'package:second_music/common/md5.dart';
import 'package:second_music/model/album.dart';
import 'package:second_music/model/enum.dart';
import 'package:second_music/model/playlist.dart';
import 'package:second_music/model/playlist_set.dart';
import 'package:second_music/model/search.dart';
import 'package:second_music/model/singer.dart';
import 'package:second_music/model/song.dart';
import 'package:second_music/model/user.dart';
import 'package:second_music/network/cookie.dart';
import 'package:second_music/network/http_maker.dart';
import 'package:second_music/network/platform/music_provider.dart';

typedef T ConvertItem<T>(Map<String, dynamic> data);

class XiamiMusic extends BaseMusicProvider {
  XiamiMusic(HttpMaker httpMaker) : super(httpMaker);

  @override
  Future<PlaylistSet> showPlayList({int offset = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    const api = '/api/list/collect';
    var page = (offset / 30).floor() + 1;
    var pageSize = 60;
    var params = <String, dynamic>{
      'pagingVO': {
        'page': page,
        'pageSize': pageSize,
      },
      'dataType': 'system',
    };

    var response = await _httpGetForApi(api, params);
    var respJson = json.decode(response);
    var respResult = Json.getObject<Map>(respJson, 'result');
    var respResultData = Json.getObject<Map>(respResult, 'data');
    var respResultDataCollections = Json.getObject<List>(respResultData, 'collects');
    var playlists =
        respResultDataCollections.map<Playlist>((item) => _convertPlaylist(item)).toList();

    var pageVOJson = Json.getObject<Map>(respResultData, 'pagingVO');

    var playlistSet = PlaylistSet()
      ..hasNext = Json.getInt(pageVOJson, 'pages') > page
      ..playlists = playlists;
    return playlistSet;
  }

  @override
  Future<Playlist> playList(String listId,
      {int offset = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    const api = '/api/collect/initialize';
    var listIdInt = int.tryParse(listId, radix: 10) ?? 0;
    var params = {'listId': listIdInt};
    var response = await _httpGetForApi(api, params);

    var respJson = json.decode(response);
    var resultJson = Json.getObject<Map>(respJson, 'result');
    var dataJson = Json.getObject<Map>(resultJson, 'data');
    var detailJson = Json.getObject<Map>(dataJson, 'collectDetail');

    var songsJson = Json.getObject<List>(dataJson, 'collectSongs');
    var songs = songsJson?.map<Song>((item) => _convertSong(item))?.toList();

    var creatorJson = Json.getObject(detailJson, 'user');
    var creator = User()
      ..plt = MusicPlatforms.XIAMI
      ..id = Json.getString(creatorJson, 'userId')
      ..name = Json.getString(creatorJson, 'nickName')
      ..avatar = Json.getString(creatorJson, 'avatar');

    var playlist = Playlist()
      ..plt = MusicPlatforms.XIAMI
      ..id = Json.getString(detailJson, 'listId')
      ..title = Json.getString(detailJson, 'collectName')
      ..cover = Json.getString(detailJson, 'collectLogo')
      ..playCount = Json.getInt(detailJson, 'playCount')
      ..favorCount = Json.getInt(detailJson, 'collects')
      ..description = Json.getString(detailJson, 'description')
      ..creator = creator
      ..songs = songs;

    return playlist;
  }

  @override
  Future<bool> parseTrack(Song song) async {
    var url = 'http://emumo.xiami.com/song/playlist/id/${song.id}/'
        'object_name/default/object_id/0/cat/json';
    String response = await httpMaker(
        {HttpMakerParams.url: url, HttpMakerParams.method: HttpMakerParams.methodGet});

    var respJson = json.decode(response);
    var dataJson = Json.getObject<Map<String, dynamic>>(respJson, 'data');
    var listJson = Json.getObject<List>(dataJson, 'trackList');
    if (listJson == null || listJson.isEmpty) {
      return false;
    }
    song.streamUrl = handleProtocolRelativeUrl(caesar(listJson.first['location']));
    song.lyricUrl = handleProtocolRelativeUrl(listJson.first['lyric_url']);
    return true;
  }

  @override
  Future<String> lyric(String songId) {}

  Future<SearchResult> searchSongs(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) {
    const api = '/api/search/searchSongs';
    return _searchItemsInternal(keyword, api, page: page, count: count);
  }

  Future<SearchResult> searchAlbums(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) {
    const api = '/api/search/searchAlbums';
    return _searchItemsInternal(keyword, api, page: page, count: count);
  }

  @override
  Future<SearchResult> searchPlaylists(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) {
    const api = '/api/search/searchCollects';
    return _searchItemsInternal(keyword, api, page: page, count: count);
  }

  @override
  Future<SearchResult> searchSingers(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) {
    const api = '/api/search/searchArtists';
    return _searchItemsInternal(keyword, api, page: page, count: count);
  }

  Future<SearchResult> _searchItemsInternal(String keyword, String api,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    var params = {
      'pagingVO': {
        'page': page,
        'pageSize': count ?? 20,
      },
      'key': keyword,
    };

    var response = await _httpGetForApi(api, params);
    var jsonObj = json.decode(response);
    var resultJson = Json.getObject<Map>(jsonObj, 'result');
    var dataJson = Json.getObject<Map>(resultJson, 'data');

    var pageJson = Json.getObject<Map>(dataJson, 'pagingVO');
    var total = Json.getInt(pageJson, 'count');

    if (dataJson == null) return null;

    if (dataJson.containsKey('songs')) {
      var songsJson = Json.getObject<List>(dataJson, 'songs');
      var songs = songsJson?.map((item) => _convertSong(item))?.toList();
      return SearchResult()
        ..total = total
        ..items = songs;
    }

    if (dataJson.containsKey('albums')) {
      var albumsJson = Json.getObject<List>(dataJson, 'albums');
      var albums = albumsJson?.map((item) => _convertAlbum(item))?.toList();
      return SearchResult()
        ..total = total
        ..items = albums;
    }

    if (dataJson.containsKey('collects')) {
      var playlistsJson = Json.getObject<List>(dataJson, 'collects');
      var playlists = playlistsJson?.map((item) => _convertPlaylist(item))?.toList();
      return SearchResult()
        ..total = total
        ..items = playlists;
    }

    if (dataJson.containsKey('artists')) {
      var singersJson = Json.getObject<List>(dataJson, 'artists');
      var singers = singersJson?.map((item) => _convertSinger(item))?.toList();
      return SearchResult()
        ..total = total
        ..items = singers;
    }

    return null;
  }

  @override
  Future<Album> album(String albumId, {int offset, int count = DEFAULT_REQUEST_COUNT}) async {
    var url =
        'http://api.xiami.com/web?v=2.0&app_key=1&id=$albumId&page=1&limit=20&callback=jsonp217&r=album/detail';
    String result = await httpMaker(
        {HttpMakerParams.url: url, HttpMakerParams.method: HttpMakerParams.methodGet});
    var jsonStr = result.substring('jsonp217('.length, result.length - ')'.length);
    var jsonMap = json.decode(jsonStr);
    var dataJson = Json.getObject<Map>(jsonMap, 'data');

    var songsJson = Json.getObject<List>(dataJson, 'songs');
    var songs = songsJson.map<Song>((songJson) => _covertSong2(songJson)).toList();

    var singer = Singer()
      ..plt = MusicPlatforms.XIAMI
      ..id = Json.getInt(dataJson, 'artist_id').toString()
      ..name = Json.getString(dataJson, 'artist_name');

    var album = Album()
      ..plt = MusicPlatforms.XIAMI
      ..id = Json.getInt(dataJson, 'album_id').toString()
      ..name = Json.getString(dataJson, 'album_name')
      ..cover = Json.getString(dataJson, 'album_logo')
      ..releaseTime = dateTimeToString(
          DateTime.fromMillisecondsSinceEpoch(Json.getInt(dataJson, 'gmt_publish') * 1000))
      ..singers = [singer]
      ..songTotal = Json.getInt(dataJson, 'song_count')
      ..songs = songs;
    return album;
  }

  @override
  Future<Singer> singer(String artistId, MusicObjectType type,
      {int offset = 0, int count = DEFAULT_REQUEST_COUNT}) {}

  @override
  String userSource(String userId) => 'https://www.xiami.com/user/$userId';

  @override
  String songSource(String songId) => 'https://www.xiami.com/song/$songId';

  @override
  String albumSource(String albumId) => 'https://www.xiami.com/album/$albumId';

  @override
  String singerSource(String singerId) => 'https://www.xiami.com/artist/$singerId';

  @override
  String playlistSource(String playlistId) => 'https://www.xiami.com/collect/$playlistId';

  @override
  String get platform => MusicPlatforms.XIAMI;

  Future<String> _httpGetForApi(String api, dynamic params) async {
    var token = _getToken();
    var url = _makeApiUrl(api, params, token);
    var response = await httpMaker(
        {HttpMakerParams.url: url, HttpMakerParams.method: HttpMakerParams.methodGet});
    var respJson = json.decode(response);
    var respCode = Json.getString(respJson, 'code');
    if (respCode == 'SG_TOKEN_EMPTY' ||
        respCode == 'SG_TOKEN_EXPIRED' ||
        respCode == 'SG_INVALID') {
      var token2 = _getToken();
      var url2 = _makeApiUrl(api, params, token2);
      response = await httpMaker(
          {HttpMakerParams.url: url2, HttpMakerParams.method: HttpMakerParams.methodGet});
    }
    return response;
  }

  String _getToken() {
    const domain = 'https://www.xiami.com';
    var cookies = cookieJar.loadForRequest(Uri.parse(domain));
    var index = cookies.indexWhere((item) => item.name == 'xm_sg_tk');
    return index == -1 ? '' : cookies[index].value;
  }

  String _makeApiUrl(String api, dynamic params, String token) {
    var paramsString = json.encode(params);
    var origin = '${token.split('_')[0]}_xmMain_${api}_$paramsString';
    var sign = md5(origin);
    var baseUrl = 'https://www.xiami.com';
    return Uri.encodeFull('$baseUrl$api?_q=$paramsString&_s=$sign');
  }

  Song _convertSong(Map<String, dynamic> json) {
    var album = Album()
      ..plt = MusicPlatforms.XIAMI
      ..id = Json.getString(json, 'albumId')
      ..name = Json.getString(json, 'albumName')
      ..cover = Json.getString(json, 'albumLogo');

    var singer = Singer()
      ..plt = MusicPlatforms.XIAMI
      ..id = Json.getString(json, 'artistId')
      ..name = Json.getString(json, 'artistName')
      ..avatar = Json.getString(json, 'artistLogo');

    var song = Song()
      ..plt = MusicPlatforms.XIAMI
      ..id = Json.getString(json, 'songId')
      ..name = Json.getString(json, 'songName')
      ..cover = Json.getString(json, 'albumLogo')
      ..description = Json.getString(json, 'description')
      ..album = album
      ..singer = singer;

    return song;
  }

  Song _covertSong2(Map<String, dynamic> json) {
    var album = Album()
      ..plt = MusicPlatforms.XIAMI
      ..id = Json.getString(json, 'album_id')
      ..name = Json.getString(json, 'album_name')
      ..cover = Json.getString(json, 'album_logo');

    var singer = Singer()
      ..plt = MusicPlatforms.XIAMI
      ..id = Json.getString(json, 'artist_id')
      ..name = Json.getString(json, 'singers');

    var song = Song()
      ..plt = MusicPlatforms.XIAMI
      ..id = Json.getString(json, 'song_id')
      ..name = Json.getString(json, 'song_name')
      ..cover = Json.getString(json, 'album_logo')
      ..album = album
      ..singer = singer;

    return song;
  }

  Album _convertAlbum(Map<String, dynamic> json) {
    var singersJson = Json.getObject<List>(json, 'artists');
    var singers = singersJson?.map((item) => _convertSinger(item))?.toList();

    return Album()
      ..plt = MusicPlatforms.XIAMI
      ..id = Json.getString(json, 'albumStringId')
      ..name = Json.getString(json, 'albumName')
      ..cover = Json.getString(json, 'albumLogo')
      ..releaseTime = dateTimeToString(
          DateTime.fromMillisecondsSinceEpoch(Json.getInt(json, 'gmtPublish') * 1000))
      ..playCount = Json.getInt(json, 'playCount')
      ..favorCount = Json.getInt(json, 'collects')
      ..singers = singers
      ..songTotal = Json.getInt(json, 'songCount');
  }

  Singer _convertSinger(Map<String, dynamic> json) {
    return Singer()
      ..plt = MusicPlatforms.XIAMI
      ..id = Json.getString(json, 'artistStringId')
      ..name = Json.getString(json, 'artistName')
      ..avatar = Json.getString(json, 'artistLogo');
  }

  Playlist _convertPlaylist(Map<String, dynamic> json) {
    var creator = User()
      ..plt = MusicPlatforms.XIAMI
      ..id = Json.getString(json, 'userId')
      ..name = Json.getString(json, 'userName')
      ..avatar = Json.getString(json, 'authorAvatar');

    return Playlist()
      ..plt = MusicPlatforms.XIAMI
      ..id = Json.getString(json, 'listId')
      ..title = Json.getString(json, 'collectName')
      ..cover = Json.getString(json, 'collectLogo')
      ..playCount = Json.getInt(json, 'playCount')
      ..creator = creator
      ..songTotal = Json.getInt(json, 'songCount');
  }

  String caesar(String location) {
    var num = int.parse(location.substring(0, 1));
    var avgLen = ((location.length - 1) / num).floor();
    var remainder = (location.length - 1) % num;

    var result = <String>[];
    for (var i = 0; i < remainder; i += 1) {
      var line = location.substring(i * (avgLen + 1) + 1, (i + 1) * (avgLen + 1) + 1);
      result.add(line);
    }

    for (var i = 0; i < num - remainder; i += 1) {
      var line = location
          .substring((avgLen + 1) * remainder)
          .substring(i * avgLen + 1, (i + 1) * avgLen + 1);
      result.add(line);
    }

    var sb = StringBuffer();
    for (var i = 0; i < avgLen; i += 1) {
      for (var j = 0; j < num; j += 1) {
        sb.write(result[j].substring(i, i + 1));
      }
    }

    for (var i = 0; i < remainder; i += 1) {
      sb.write(result[i].substring(result[i].length - 1));
    }

    var str1 = Uri.decodeComponent(sb.toString());
    var str2 = str1.replaceAll(RegExp(r'\^'), '0');
    return str2;
  }

  String handleProtocolRelativeUrl(String url) {
    return url.replaceFirst(RegExp(r'^.*\/\/'), 'http://');
  }
}
