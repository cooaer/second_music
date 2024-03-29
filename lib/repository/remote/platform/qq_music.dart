import 'dart:convert';
import 'dart:math';

import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:flutter/foundation.dart';
import 'package:second_music/app.dart';
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

class QQMusic extends BaseMusicProvider {
  QQMusic(HttpMaker httpMaker) : super(httpMaker);

  @override
  Future<PlaylistSet?> showPlayList(
      {int offset = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    final targetUrl =
        'https://c.y.qq.com/splcloud/fcgi-bin/fcg_get_diss_by_tag.fcg'
        '?picmid=1&rnd=${Random().nextDouble()}&g_tk=732560869'
        '&loginUin=0&hostUin=0&format=json&inCharset=utf8&outCharset=utf-8'
        '&notice=0&platform=yqq.json&needNewCode=0'
        '&categoryId=10000000&sortId=5&sin=$offset&ein=${19 + offset}';
    final response = await httpMaker.get(targetUrl);
    if (response.isEmpty) {
      return null;
    }

    Map<String, dynamic> data = jsonDecode(response);
    final dataData = Json.getMap(data, 'data');
    final dataDataList = Json.getList(dataData, 'list');
    final playlists =
        dataDataList.map<Playlist>((item) => _convertPlaylist(item)).toList();

    return PlaylistSet()
      ..hasNext = true
      ..playlists = playlists;
  }

  @override
  Future<String> lyric(String songId) async {
    return "";
  }

  @override
  Future<bool> parseSoundUrl(Song song) async {
    await _parseSoundUrl([song]);
    return true;
  }

  Future<void> _parseSoundUrl(List<Song> songs) async {
    final _parseSoundUrlInternal = (List<Song> songs) async {
      final url = 'https://u.y.qq.com/cgi-bin/musicu.fcg';
      final guid = '10000';
      final songIdList = songs.map((song) => song.pltId).toList();
      final uin = '0';

      final fileType = '128';
      final fileConfig = {
        'm4a': {
          's': 'C400',
          'e': '.m4a',
          'bitrate': 'M4A',
        },
        '128': {
          's': 'M500',
          'e': '.mp3',
          'bitrate': '128kbps',
        },
        '320': {
          's': 'M800',
          'e': '.mp3',
          'bitrate': '320kbps',
        },
        'ape': {
          's': 'A000',
          'e': '.ape',
          'bitrate': 'APE',
        },
        'flac': {
          's': 'F000',
          'e': '.flac',
          'bitrate': 'FLAC',
        },
      };
      final fileInfo = fileConfig[fileType];
      final fileNames = songs
          .map((song) =>
              "${fileInfo?['s']}${song.pltId}${song.pltId}${fileInfo?['e']}")
          .toList();

      final reqData = {
        'req_0': {
          'module': 'vkey.GetVkeyServer',
          'method': 'CgiGetVkey',
          'param': {
            'filename': fileNames,
            'guid': guid,
            'songmid': songIdList,
            'songtype': [0],
            'uin': uin,
            'loginflag': 1,
            'platform': '20',
          },
        },
        'loginUin': uin,
        'comm': {
          'uin': uin,
          'format': 'json',
          'ct': 24,
          'cv': 0,
        },
      };
      final params = {
        'format': 'json',
        'data': jsonEncode(reqData),
      };

      final httpResult = await httpMaker.get(url, queryParameters: params);

      debugPrint("QQMusic.parseSoundUrl, httpResult = $httpResult");
      final Map<String, dynamic>? respJson = json.decode(httpResult);
      final List<dynamic>? sips = respJson?['req_0']?['data']?['sip'];
      final String? baseUrl = sips.isNotNullOrEmpty() ? sips!.first : null;
      if (baseUrl.isNullOrEmpty()) {
        return;
      }
      final List<dynamic>? midUrlInfos =
          respJson?['req_0']?['data']?['midurlinfo'];
      if (midUrlInfos == null) {
        return;
      }
      //item中的result=104003，表示由于版权原因无法获取url
      final Map<String, String> idUrls = Map.fromIterable(midUrlInfos,
          key: (item) => item['songmid'], value: (item) => item['purl']);
      for (var song in songs) {
        final purl = idUrls[song.pltId];
        if (purl.isNullOrEmpty()) {
          continue;
        }
        song.soundUrl = baseUrl! + purl!;
        debugPrint(
            "QQMusic.parseSoundUrl: name = ${song.name}, url = ${song.soundUrl}");
      }
    };

    var startIndex = 0;
    while (startIndex < songs.length) {
      await _parseSoundUrlInternal(
          songs.sublist(startIndex, min(startIndex + 20, songs.length)));
      startIndex += 20;
    }
  }

  @override
  Future<Album?> album(String albumId) async {
    final url = 'http://i.y.qq.com/v8/fcg-bin/fcg_v8_album_info_cp.fcg?'
        'platform=h5page&albummid=$albumId&g_tk=938407465&uin=0&'
        'format=jsonp&inCharset=utf-8&outCharset=utf-8&notice=0&'
        'platform=h5&needNewCode=1&_=1459961045571&'
        'jsonpCallback=asonglist1459961045566';

    final result = await httpMaker.get(url);
    if (result.isEmpty) {
      return null;
    }
    final jsonStr = result.substring(
        ' asonglist1459961045566('.length, result.length - ')'.length);
    final jsonMap = json.decode(jsonStr);
    final dataJson = Json.getMap(jsonMap, 'data');
    final listJson = Json.getList(dataJson, 'list');

    final songs = listJson.map((item) => _convertSong2(item)).toList();
    // await _parseSoundUrl(songs);

    final singer = Singer()
      ..plt = MusicPlatform.qq
      ..pltId = Json.getString(dataJson, 'singermid')
      ..name = Json.getString(dataJson, 'singername');

    final album = Album()
      ..plt = MusicPlatform.qq
      ..pltId = Json.getString(dataJson, 'mid')
      ..name = Json.getString(dataJson, 'name')
      ..cover =
          _getImageUrl(Json.getString(dataJson, 'mid'), MusicObjectType.album)
      ..releaseTime = Json.getString(dataJson, 'aDate')
      ..description = Json.getString(dataJson, 'desc')
      ..singers = [singer]
      ..songTotal = Json.getInt(dataJson, 'total')
      ..songs = songs;

    return album;
  }

  @override
  Future<Singer?> singer(String singerId) async {
    return null;
  }

  @override
  Future<Singer?> singerAlbums(String singerId,
      {int offset = 0, int count = DEFAULT_REQUEST_SINGER_ALBUMS_COUNT}) async {
    final singerJson = await _singerItems(singerId, MusicObjectType.album,
        offset: offset, count: count);
    final dataJson = singerJson.getMap('data');

    final albumsJson = dataJson.getList('list');
    final albums = albumsJson.map((e) => _convertAlbum3(e)).toList();

    return Singer()
      ..plt = MusicPlatform.qq
      ..pltId = dataJson.getString('singer_mid')
      ..name = dataJson.getString('singer_name')
      ..avatar = _getImageUrl(singerId, MusicObjectType.singer)
      ..albumTotal = dataJson.getInt('total')
      ..albums = albums;
  }

  @override
  Future<Singer?> singerSongs(String singerId,
      {int offset = 0, int count = DEFAULT_REQUEST_SINGER_SONGS_COUNT}) async {
    final singerJson = await _singerItems(singerId, MusicObjectType.song,
        offset: offset, count: count);

    final dataJson = singerJson.getMap('data');

    final songsJson = dataJson.getList('songlist');
    final songs = songsJson.map((e) => _convertSong(e)).toList();

    final singerInfoJson = dataJson.getMap('singer_info');
    return Singer()
      ..plt = MusicPlatform.qq
      ..pltId = singerInfoJson.getString('mid')
      ..name = singerInfoJson.getString('name')
      ..avatar = _getImageUrl(singerId, MusicObjectType.singer)
      ..introduction = dataJson.getString('singer_brief')
      ..albumTotal = dataJson.getInt('total_album')
      ..songTotal = dataJson.getInt('total_song')
      ..songs = songs;
  }

  Future<Map<String, dynamic>> _singerItems(
      String singerId, MusicObjectType type,
      {int offset = 0, int count = DEFAULT_REQUEST_SINGER_SONGS_COUNT}) async {
    var dataMethod = '';
    switch (type) {
      case MusicObjectType.song:
        dataMethod = 'get_singer_detail_info';
        break;
      case MusicObjectType.album:
        dataMethod = 'get_singer_album';
        break;
      default:
        break;
    }
    final dataParams = {
      'comm': {
        'ct': 24,
        'cv': 0,
      },
      'singer': {
        'method': dataMethod,
        'param': {
          'sort': 5,
          'order': 'time',
          'singermid': singerId,
          'begin': offset,
          'num': count,
          'exstatus': 1,
        },
        'module': 'music.web_singer_info_svr',
      },
    };
    final data = jsonEncode(dataParams);
    final targetUrl =
        'https://u.y.qq.com/cgi-bin/musicu.fcg?format=json&loginUin=0'
        '&hostUin=0inCharset=utf8&outCharset=utf-8&platform=yqq.json'
        '&needNewCode=0&data=$data';
    final httpResp = await httpMaker.get(targetUrl);

    final respJson = jsonDecode(httpResp) as Map<String, dynamic>;
    final singerJson = respJson.getMap('singer');
    return singerJson;
  }

  @override
  Future<Playlist?> playlist(String listId) async {
    // final targetUrl =
    //     'https://c.y.qq.com/qzone/fcg-bin/fcg_ucc_getcdinfo_byids_cp.fcg?'
    //     'type=1&json=1&utf8=1&onlysong=0&new_format=1&disstid=$listId&g_tk=1062527372&'
    //     '&loginUin=1064549797hostUin=0&format=json&inCharset=utf8&outCharset=utf-8&notice=0&'
    //     'platform=yqq.json&needNewCode=0';

    final targetUrl =
        'http://i.y.qq.com/qzone-music/fcg-bin/fcg_ucc_getcdinfo_byids_cp.fcg?' +
            'type=1&json=1&utf8=1&onlysong=0&nosign=1&disstid=$listId' +
            '&g_tk=5381&loginUin=0&hostUin=0&format=json&inCharset=GB2312' +
            '&outCharset=utf-8&notice=0&platform=yqq&needNewCode=0';

    String response = await httpMaker.get(targetUrl);
    if (response.isEmpty) {
      return null;
    }
    Map<String, dynamic> data = json.decode(response);
    Map<String, dynamic> dataCdlist0 = Json.getList(data, 'cdlist').first;

    final creator = User();
    creator.plt = MusicPlatform.qq;
    creator.pltId = Json.getString(dataCdlist0, 'uin');
    creator.name =
        App.htmlUnescape.convert(Json.getString(dataCdlist0, 'nick'));
    creator.avatar = Json.getString(dataCdlist0, 'headurl');

    final listJson = Json.getList(dataCdlist0, 'songlist');
    final songList = listJson.map((e) => _convertSong2(e)).toList();

    final playlist = Playlist();
    playlist.pltId = listId;
    playlist.plt = MusicPlatform.qq;
    playlist.title =
        App.htmlUnescape.convert(Json.getString(dataCdlist0, 'dissname'));
    playlist.cover = Json.getString(dataCdlist0, 'logo');
    playlist.description = Json.getString(dataCdlist0, 'desc');
    playlist.playCount = Json.getInt(dataCdlist0, 'visitnum');
    playlist.creator = creator;

    playlist.songTotal = Json.getInt(dataCdlist0, 'songnum');
    playlist.songs = songList;
    return playlist;
  }

  @override
  Future<SearchResult?> searchPlaylist(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    final enKeyword = Uri.encodeComponent(keyword);
    final searchId = (Random().nextDouble() * 9655).floor().toString();

    // page 从1开始
    final url = 'https://c.y.qq.com/soso/fcgi-bin/client_music_search_songlist?'
        'page_no=$page&query=$enKeyword&format=json&outCharset=utf-8&inCharset=utf-8&'
        'num_per_page=$count&searchid=$searchId&remoteplace=txt.mac.search';

    debugPrint(
        'qq.searchPlaylist, keyword = $keyword, page = $page, count = $count');

    final String response = await httpMaker.get(url);

    if (response.isEmpty) {
      return null;
    }

    final respJson = json.decode(response);
    final dataJson = Json.getMap(respJson, 'data');
    final listJson = Json.getList(dataJson, 'list');
    final playlists = listJson.map((item) => _convertPlaylist(item)).toList();

    return SearchResult()
      ..total = Json.getInt(dataJson, 'sum')
      ..items = playlists;
  }

  //搜索接口，抓包自QQ音乐客户端
//  https://c.y.qq.com/soso/fcgi-bin/client_search_cp?g_tk=5381&p=1&n=20&
//  w=%E6%AC%A7%E9%98%B3%E6%9C%B5&format=jsonp&jsonpCallback=callback&
//  loginUin=0&hostUin=0&inCharset=utf8&outCharset=utf-8&notice=0&
//  platform=yqq&needNewCode=0&remoteplace=txt.yqq.song&t=0&aggr=1&cr=1&flag_qc=0

  // w：搜索词
  // t: 搜索类型，0：歌曲，8：专辑
  // p: 当前页
  // n: 每页歌曲数目

  @override
  Future<SearchResult?> searchSong(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) {
    return _searchCpInternal(keyword, 0, 0, page: page, count: count);
  }

  @override
  Future<SearchResult?> searchAlbum(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) {
    return _searchCpInternal(keyword, 8, 0, page: page, count: count);
  }

  @override
  Future<SearchResult?> searchSinger(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) {
    return _searchCpInternal(keyword, 0, 1, page: page, count: count);
  }

  /// 搜索歌曲、专辑、歌手，
  /// type, 0:歌曲，8:专辑，1:mv,
  /// catZhida=1，返回歌手信息
  Future<SearchResult?> _searchCpInternal(
      String keyword, int type, int catZhida,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    final enKeyword = Uri.encodeComponent(keyword);

    final targetUrl = 'https://c.y.qq.com/soso/fcgi-bin/search_for_qq_cp?'
        'g_tk=5381&uin=0&format=json&inCharset=utf-8&outCharset=utf-8¬ice=0'
        '&platform=h5&needNewCode=1&w=$enKeyword&zhidaqu=1&catZhida=$catZhida&t=$type&flag=1'
        '&ie=utf-8&sem=1&aggr=0&perpage=$count&n=$count&p=$page&remoteplace=txt.mqq.all'
        '&_=1520833663464';

    debugPrint(
        'qq.search, type = $type, keyword = $keyword, page = $page, count = $count');

    final response = await httpMaker.get(targetUrl);

    if (response.isEmpty) {
      return null;
    }

    final respJson = json.decode(response);
    final dataJson = Json.getMap(respJson, 'data');

    final result = SearchResult();

    if (dataJson.containsKey('zhida')) {
      final zhidaJson = Json.getMap(dataJson, 'zhida');
      if (zhidaJson.containsKey('singermid')) {
        final singer = _convertSinger2(zhidaJson);
        result.total = 1;
        result.items = [singer];
        return result;
      }
    }

    if (catZhida == 1) {
      return null;
    }

    if (dataJson.containsKey('song')) {
      final songJson = Json.getMap(dataJson, 'song');
      final listJson = Json.getList(songJson, 'list');
      final songs = listJson.map((e) => _convertSong2(e)).toList();

      result.total = Json.getInt(songJson, 'totalnum');
      result.items = songs;
      return result;
    }

    if (dataJson.containsKey('album')) {
      final albumJson = Json.getMap(dataJson, 'album');
      final listJson = Json.getList(albumJson, 'list');
      result.total = Json.getInt(albumJson, 'totalnum');
      result.items = listJson.map((item) => _convertAlbum2(item)).toList();
      return result;
    }
    return result;
  }

  @override
  bool get showPlayListEnabled => true;

  String playlistSource(String playlistId) =>
      'https://y.qq.com/n/yqq/playlist/$playlistId.html';

  String singerSource(String singerId) =>
      'https://y.qq.com/n/yqq/singer/$singerId.html';

  String albumSource(String albumId) =>
      'https://y.qq.com/n/yqq/album/$albumId.html';

  String songSource(String songId) =>
      'https://y.qq.com/n/yqq/song/$songId.html';

  String userSource(String userId) =>
      'https://y.qq.com/portal/profile.html?uin=$userId';

  @override
  MusicPlatform get platform => MusicPlatform.qq;

  Song _convertSong(Map<String, dynamic> songJson) {
    // debugPrint("qq.convertSong, json = $songJson");
    final singerListJson = Json.getList(songJson, 'singer');
    final singerList = singerListJson.map((item) {
      final singer = Singer()
        ..plt = MusicPlatform.qq
        ..pltId = Json.getString(item, 'mid')
        ..name = Json.getString(item, 'name');
      return singer;
    }).toList();

    final albumJson = Json.getMap(songJson, 'album');
    final album = Album()
      ..plt = MusicPlatform.qq
      ..pltId = Json.getString(albumJson, 'mid')
      ..name = Json.getString(albumJson, 'name')
      ..subtitle = Json.getString(albumJson, 'subtitle');

    final song = Song()
      ..plt = MusicPlatform.qq
      ..pltId = Json.getString(songJson, 'mid')
      ..name = Json.getString(songJson, 'name')
      ..subtitle = Json.getString(songJson, 'subtitle')
      ..cover = _getImageUrl(album.pltId, MusicObjectType.album)
      ..singers = singerList
      ..album = album;

    return song;
  }

  Song _convertSong2(Map<String, dynamic> songJson) {
    final singerListJson = Json.getList(songJson, 'singer');
    final singerList = singerListJson.map((item) {
      final singer = Singer()
        ..plt = MusicPlatform.qq
        ..pltId = Json.getString(item, 'mid')
        ..name = Json.getString(item, 'name');
      return singer;
    }).toList();

    final albumId = Json.getString(songJson, 'albummid');
    final album = Album()
      ..plt = MusicPlatform.qq
      ..pltId = albumId
      ..name = Json.getString(songJson, 'albumname');

    final song = Song()
      ..plt = MusicPlatform.qq
      ..pltId = Json.getString(songJson, 'songmid')
      ..name = Json.getString(songJson, 'songname')
      ..subtitle = Json.getString(songJson, 'lyric')
      ..cover = _getImageUrl(albumId, MusicObjectType.album)
      ..isPlayable = _isQQSongPlayable(Json.getInt(songJson, "switch"))
      ..singers = singerList
      ..album = album;

    return song;
  }

  Album _convertAlbum(Map<String, dynamic> json) {
    final singerJson = Json.getList(json, 'singer_list');
    final singers = singerJson.map((item) {
      final singer = Singer()
        ..plt = MusicPlatform.qq
        ..pltId = Json.getString(item, 'mid')
        ..name = Json.getString(item, 'name');
      return singer;
    }).toList();

    return Album()
      ..plt = MusicPlatform.qq
      ..pltId = Json.getString(json, 'albumMID')
      ..name = Json.getString(json, 'albumName')
      ..cover = Json.getString(json, 'albumPic')
      ..releaseTime = Json.getString(json, 'publicTime')
      ..singers = singers
      ..songTotal = Json.getInt(json, 'song_count');
  }

  Album _convertAlbum2(Map<String, dynamic> json) {
    final singer = Singer()
      ..plt = MusicPlatform.qq
      ..pltId = Json.getString(json, 'singerMID')
      ..name = Json.getString(json, 'singerName');

    final albumId = Json.getString(json, 'albumMID');
    return Album()
      ..plt = MusicPlatform.qq
      ..pltId = albumId
      ..name = Json.getString(json, 'albumName')
      ..cover = _getImageUrl(albumId, MusicObjectType.album)
      ..releaseTime = Json.getString(json, 'publicTime')
      ..singers = [singer];
  }

  Album _convertAlbum3(Map<String, dynamic> json) {
    final singersJson = json.getList('singers');
    final singers = singersJson.map((e) => _convertSinger3(e)).toList();
    final albumId = Json.getString(json, 'album_mid');
    return Album()
      ..plt = MusicPlatform.qq
      ..pltId = albumId
      ..name = Json.getString(json, 'album_name')
      ..cover = _getImageUrl(albumId, MusicObjectType.album)
      ..description = Json.getString(json, 'desc')
      ..releaseTime = Json.getString(json, 'pub_time')
      ..singers = singers;
  }

  Singer _convertSinger(Map<String, dynamic> json) {
    final albumsJson = Json.getList(json, 'hotalbum');
    final albums = albumsJson.map((item) {
      return Album()
        ..plt = platform
        ..pltId = Json.getString(item, 'albumMID')
        ..name = Json.getString(item, 'albumName');
    }).toList();

    final songsJson = Json.getList(json, 'hotsong');
    final songs = songsJson.map((item) {
      return Song()
        ..plt = platform
        ..pltId = Json.getString(item, 'songMID')
        ..name = Json.getString(item, 'songName');
    }).toList();

    return Singer()
      ..plt = platform
      ..pltId = Json.getString(json, 'singerID')
      ..name = Json.getString(json, 'singerName')
      ..avatar = Json.getString(json, 'singerPic')
      ..albumTotal = Json.getInt(json, 'albumNum')
      ..albums = albums
      ..songTotal = Json.getInt(json, 'songNum')
      ..songs = songs;
  }

  Singer _convertSinger2(Map<String, dynamic> json) {
    final singerId = Json.getString(json, 'singermid');
    return Singer()
      ..plt = platform
      ..pltId = singerId
      ..name = Json.getString(json, 'singername')
      ..avatar = _getImageUrl(singerId, MusicObjectType.singer)
      ..songTotal = Json.getInt(json, 'songnum');
  }

  Singer _convertSinger3(Map<String, dynamic> json) {
    final singerId = Json.getString(json, 'singer_mid');
    return Singer()
      ..plt = platform
      ..pltId = singerId
      ..name = Json.getString(json, 'singer_name')
      ..avatar = _getImageUrl(singerId, MusicObjectType.singer);
  }

  Playlist _convertPlaylist(Map<String, dynamic> json) {
    final creatorJson = Json.getMap(json, 'creator');
    final creator = User()
      ..plt = MusicPlatform.qq
      ..pltId = Json.getString(creatorJson, 'encrypt_uin')
      ..name = App.htmlUnescape.convert(Json.getString(creatorJson, 'name'))
      ..avatar = Json.getString(creatorJson, 'avatarUrl');

    return Playlist()
      ..plt = MusicPlatform.qq
      ..pltId = Json.getString(json, 'dissid')
      ..title = App.htmlUnescape.convert(Json.getString(json, 'dissname'))
      ..cover = Json.getString(json, 'imgurl')
      ..playCount = Json.getInt(json, 'listennum')
      ..description = Json.getString(json, 'introduction')
      ..creator = creator
      ..songTotal = Json.getInt(json, 'song_count');
  }

  String _getImageUrl(String imageId, MusicObjectType imageType) {
    if (imageId.isEmpty) {
      return '';
    }
    var category = '';
    if (imageType == MusicObjectType.singer) {
      category = 'mid_singer_500';
    }
    if (imageType == MusicObjectType.album) {
      category = 'mid_album_500';
    }

    final params =
        '$category/${imageId.substring(imageId.length - 2, imageId.length - 1)}/${imageId.substring(imageId.length - 1)}/$imageId';
    final url = 'http://imgcache.qq.com/music/photo/$params.jpg';
    return url;
  }

  bool _isQQSongPlayable(int songSwitch) {
    return songSwitch & 0x2 == 0x2;
  }
}
