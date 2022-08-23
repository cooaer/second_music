import 'dart:convert';

import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:flutter/foundation.dart';
import 'package:second_music/common/json.dart';
import 'package:second_music/common/md5.dart';
import 'package:second_music/entity/album.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/playlist.dart';
import 'package:second_music/entity/playlist_set.dart';
import 'package:second_music/entity/search.dart';
import 'package:second_music/entity/singer.dart';
import 'package:second_music/entity/song.dart';
import 'package:second_music/entity/song_list.dart';
import 'package:second_music/entity/user.dart';
import 'package:second_music/repository/remote/http_maker.dart';
import 'package:second_music/repository/remote/platform/music_provider.dart';

class MiguMusic extends BaseMusicProvider {
  MiguMusic(HttpMaker httpMaker) : super(httpMaker);

  @override
  Future<Album> album(String albumId) async {
    final targetUrl =
        'https://app.c.nf.migu.cn/MIGUM2.0/v1.0/content/resourceinfo.do?needSimple=00&resourceType=2003&resourceId=$albumId';
    final httpResp = await httpMaker.get(targetUrl);
    final Map<String, dynamic> respJson = await jsonDecode(httpResp);
    final resourceJson = respJson.getList("resource");
    final Map<String, dynamic>? albumJson = resourceJson.firstOrNull;

    if (albumJson == null) {
      return Album();
    }

    final imgsJson = albumJson.getList('imgItems');
    final secondImgJson = imgsJson.get(1, defaultValue: <String, dynamic>{});
    final songTotal = albumJson.getInt('totalCount');
    final singerImgs = albumJson.getList('singerImgs');
    final secondSingerImg =
        singerImgs.get(1, defaultValue: <String, dynamic>{});

    final singer = Singer()
      ..plt = MusicPlatform.migu
      ..pltId = albumJson.getString('singerId')
      ..name = albumJson.getString('singer')
      ..avatar = secondSingerImg.getString('img');

    final album = Album()
      ..plt = MusicPlatform.migu
      ..pltId = albumId
      ..name = albumJson.getString("title")
      ..cover = secondImgJson.getString('img')
      ..description = albumJson.getString('summary')
      ..releaseTime = albumJson.getString('publishTime')
      ..singer = singer
      ..songTotal = songTotal
      ..songs =
          await _querySongListSongs(SongListType.album, albumId, songTotal);

    return album;
  }

  Future<List<Song>> _querySongListSongs(
      SongListType songListType, String listId, int total) async {
    final count = 50;
    final page = (total / count).ceil().toInt();
    final songs = <Song>[];
    for (int i = 0; i < page; i++) {
      songs.addAll(
          await _querySongListPageSongs(songListType, listId, i + 1, count));
    }
    return songs;
  }

  Future<List<Song>> _querySongListPageSongs(
      SongListType songListType, String listId, int page, int count) async {
    var targetUrl = "";
    switch (songListType) {
      case SongListType.playlist:
        targetUrl =
            "https://app.c.nf.migu.cn/MIGUM2.0/v1.0/user/queryMusicListSongs.do?musicListId=$listId&pageNo=$page&pageSize=$count";
        break;
      case SongListType.album:
        targetUrl =
            "https://app.c.nf.migu.cn/MIGUM2.0/v1.0/content/queryAlbumSong?albumId=$listId&pageNo=$page&pageSize=$count";
        break;
    }
    final httpResp = await httpMaker.get(targetUrl);
    final respJson = jsonDecode(httpResp);
    final List<dynamic>? songsJson;
    switch (songListType) {
      case SongListType.playlist:
        songsJson = respJson['list'];
        break;
      case SongListType.album:
        songsJson = respJson['songList'];
        break;
    }
    return songsJson?.map((map) => _convertSong(map)).toList() ?? List.empty();
  }

  Song _convertSong(Map<String, dynamic> songJson) {
    final secondAlbumImgJson =
        songJson.getList("albumImgs")[1] as Map<String, dynamic>;

    final album = Album()
      ..plt = MusicPlatform.migu
      ..pltId = songJson.getString("albumId")
      ..name = songJson.getString('album')
      ..cover = secondAlbumImgJson.getString('img');

    final singer = Singer()
      ..plt = MusicPlatform.migu
      ..pltId = songJson.getString("singerId")
      ..name = songJson.getString('singer');

    final song = Song()
      ..plt = MusicPlatform.migu
      ..pltId = songJson.getString('songId')
      ..name = songJson.getString("songName")
      ..description = songJson.getString('songDescs')
      ..cover = secondAlbumImgJson.getString("img")
      ..lyricUrl = songJson.getString('lrcUrl')
      ..isPlayable = songJson.getInt("copyright") == 1
      ..singer = singer
      ..album = album
      ..quality = songJson.getString('toneControl');
    return song;
  }

  @override
  String albumSource(String albumId) {
    return "https://music.migu.cn/v3/music/album/$albumId";
  }

  @override
  Future<String> lyric(String songId) async {
    return "";
  }

  @override
  Future<bool> parseSoundUrl(Song song) async {
    // String toneFlag;
    // switch (song.quality) {
    //   case '110000':
    //     toneFlag = 'HQ';
    //     break;
    //   case '111100':
    //     toneFlag = 'SQ';
    //     break;
    //   case '111111':
    //     toneFlag = 'ZQ';
    //     break;
    //   default:
    //     toneFlag = 'PQ';
    // }
    final targetUrl =
        'https://app.c.nf.migu.cn/MIGUM2.0/strategy/listen-url/v2.2?netType=01&resourceType=E&songId=${song.pltId}&toneFlag=PQ';
    final httpResp = await httpMaker.get(
      targetUrl,
      headers: {"channel": '0146951', "uid": 111111},
    );
    debugPrint("migu.parseTrack, result = $httpResp");
    final Map<String, dynamic> respJson = jsonDecode(httpResp);
    final dataJson = respJson.getMap('data');
    var soundUrl = dataJson.getString('url');
    if (soundUrl.isEmpty) {
      return false;
    }
    if (soundUrl.startsWith('//')) {
      soundUrl = "http:$soundUrl";
    }
    song.soundUrl = soundUrl;
    return true;
  }

  @override
  MusicPlatform get platform => MusicPlatform.migu;

  @override
  Future<Playlist> playlist(String playlistId) async {
    final targetUrl =
        'https://app.c.nf.migu.cn/MIGUM2.0/v1.0/content/resourceinfo.do?needSimple=00&resourceType=2021&resourceId=$playlistId';
    final httpResp = await httpMaker.get(targetUrl);
    final Map<String, dynamic> respJson = jsonDecode(httpResp);
    final resourceJson = respJson.getList('resource');
    final Map<String, dynamic>? playlistJson = resourceJson.firstOrNull;
    if (playlistJson == null) {
      return Playlist();
    }

    final imageItemJson = playlistJson.getMap("imgItem");
    final songTotal = playlistJson.getInt("musicNum");
    final opNumItemJson = playlistJson.getMap('opNumItem');

    final creator = User()
      ..plt = MusicPlatform.migu
      ..pltId = playlistJson.getString('ownerId')
      ..name = playlistJson.getString('ownerName')
      ..avatar = playlistJson.getString('ownerPic');

    return Playlist()
      ..plt = MusicPlatform.migu
      ..pltId = playlistId
      ..title = playlistJson.getString("title")
      ..cover = imageItemJson.getString("img")
      ..description = playlistJson.getString('summary')
      ..playCount = opNumItemJson.getInt('playNum')
      ..favorCount = opNumItemJson.getInt('keepNum')
      ..source = "https://music.migu.cn/v3/music/playlist/$playlistId"
      ..creator = creator
      ..songTotal = songTotal
      ..songs = await _querySongListSongs(
          SongListType.playlist, playlistId, songTotal);
  }

  @override
  String playlistSource(String playlistId) {
    return 'https://music.migu.cn/v3/music/playlist/$playlistId';
  }

  @override
  Future<SearchResult> searchAlbum(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    final respJson = await _searchInternal(keyword, MusicObjectType.album,
        page: page, count: count);
    final albumResultDataJson = respJson.getMap("albumResultData");
    final totalCount = albumResultDataJson.getInt("totalCount");
    final resultJson = albumResultDataJson.getList("result");
    final albums = resultJson.map((itemJson) {
      final albumJson = itemJson as Map<String, dynamic>;
      final imgItemsJson = albumJson.getList('imgItems');
      final secondImgItemJson = imgItemsJson.getMap(1);

      final singer = Singer()
        ..plt = MusicPlatform.migu
        ..name = albumJson.getString("singer");

      return Album()
        ..plt = MusicPlatform.migu
        ..pltId = albumJson.getString('id')
        ..name = albumJson.getString('name')
        ..cover = secondImgItemJson.getString('img')
        ..releaseTime = albumSource('publishTime')
        ..singer = singer
        ..songTotal = -1;
    }).toList();
    return SearchResult()
      ..total = totalCount
      ..items = albums;
  }

  @override
  Future<SearchResult> searchPlaylist(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    final respJson = await _searchInternal(keyword, MusicObjectType.playlist,
        page: page, count: count);
    final songListResultDataJson = respJson.getMap("songListResultData");
    final resultJson = songListResultDataJson.getList("result");
    final total = songListResultDataJson.getInt("totalCount");
    final playLists = resultJson.map((itemJson) {
      final playlistJson = itemJson as Map<String, dynamic>;
      final creator = User()
        ..plt = MusicPlatform.migu
        ..pltId = playlistJson.getString("userId")
        ..name = playlistJson.getString("userName");

      return Playlist()
        ..plt = MusicPlatform.migu
        ..pltId = playlistJson.getString("id")
        ..title = playlistJson.getString("name")
        ..cover = playlistJson.getString("musicListPicUrl")
        ..description = playlistJson.getString("intro")
        ..playCount = playlistJson.getInt("playNum")
        ..favorCount = playlistJson.getInt("keepNum")
        ..creator = creator
        ..songTotal = playlistJson.getInt("musicNum");
    }).toList();
    return SearchResult()
      ..total = total
      ..items = playLists;
  }

  @override
  Future<SearchResult> searchSinger(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    final respJson = await _searchInternal(keyword, MusicObjectType.singer,
        page: page, count: count);
    final singerResultDataJson = respJson.getMap("singerResultData");
    final resultJson = singerResultDataJson.getList("result");
    final totalCount = singerResultDataJson.getInt("totalCount");
    final singers = resultJson.map((json) {
      final singerJson = json as Map<String, dynamic>;
      final singerPicsJson = singerJson.getList("singerPicUrl");
      final secondSingerPicJson = singerPicsJson.getMap(1);
      return Singer()
        ..plt = MusicPlatform.migu
        ..pltId = singerJson.getString("id")
        ..name = singerJson.getString("name")
        ..avatar = secondSingerPicJson.getString("img")
        ..songTotal = singerJson.getInt("songCount")
        ..albumTotal = singerJson.getInt("albumCount");
    }).toList();
    return SearchResult()
      ..total = totalCount
      ..items = singers;
  }

  @override
  Future<SearchResult> searchSong(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    final respJson = await _searchInternal(keyword, MusicObjectType.song,
        page: page, count: count);
    final songResultDataJson = respJson.getMap("songResultData");
    final resultJson = songResultDataJson.getList("result");
    final songs = resultJson.map((songJson) => _convertSong(songJson)).toList();
    final songTotal = songResultDataJson.getInt('total');
    return SearchResult()
      ..items = songs
      ..total = songTotal;
  }

  Future<Map<String, dynamic>> _searchInternal(
      String keyword, MusicObjectType type,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    final sid =
        'USSc798b291d73849c78b6c9dc4b7ef046b51d4f04b92e84174b4c9094c19b1bdd7';
    var searchSwitch = '';
    switch (type) {
      case MusicObjectType.song:
        searchSwitch = '{"song":1}';
        break;
      case MusicObjectType.playlist:
        searchSwitch = '{"songlist":1}';
        break;
      case MusicObjectType.singer:
        searchSwitch = '{"singer":1}';
        break;
      case MusicObjectType.album:
        searchSwitch = '{"album":1}';
        break;
    }
    final encodedKeyword = Uri.encodeComponent(keyword);
    final encodedSearchSwitch = Uri.encodeComponent(searchSwitch);
    var targetUrl =
        'https://jadeite.migu.cn/music_search/v2/search/searchAll?pageNo=$page&pageSize=$count&sort=1&text=$encodedKeyword&searchSwitch=$encodedSearchSwitch&sid=$sid&isCopyright=1&isCorrect=1';

    final appId = 'yyapp2';
    final deviceId = md5(sid).toUpperCase(); // 设备的UUID
    final timestamp = DateTime.now().millisecond;
    const signatureMd5 = '6cdc72a439cef99a3418d2a78aa28c73'; // app签名证书的md5
    final text =
        "$keyword$signatureMd5${appId}d16148780a1dcc7408e06336b98cfd50$deviceId$timestamp";
    final sign = md5(text);
    final headers = {
      "appId": 'yyapp2',
      "deviceId": deviceId,
      'sign': sign,
      'timestamp': timestamp,
      'uiVersion': 'A_music_3.3.0',
      'version': '7.0.4',
    };
    final httpResp = await httpMaker.get(targetUrl, headers: headers);
    return jsonDecode(httpResp);
  }

  @override
  Future<PlaylistSet> showPlayList(
      {int offset = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    final start = offset ~/ count + 1;
    final targetUrl =
        'https://app.c.nf.migu.cn/MIGUM2.0/v2.0/content/getMusicData.do?count=$count&start=$start&templateVersion=5&type=1';
    final httpResp = await httpMaker.get(targetUrl);
    final Map<String, dynamic> respJson = await jsonDecode(httpResp);
    debugPrint("migu.showPlayList, result = $respJson");
    final List<dynamic>? contentItemList = respJson['data']['contentItemList'];
    final List<dynamic> itemList = contentItemList?.firstOrNull?['itemList'];

    final playlists = itemList.map((itemJson) {
      final barListJson = Json.getList(itemJson, 'barList');
      final playCountText = barListJson.firstOrNull['title'];
      final playList = Playlist()
        ..plt = MusicPlatform.migu
        ..pltId = _playListIdFromActionUrl(itemJson['actionUrl'])
        ..title = itemJson['title']
        ..cover = itemJson['imageUrl']
        ..playCount = _playCountFromText(playCountText);
      return playList;
    }).toList();

    final playlistSet = PlaylistSet()
      ..hasNext = true
      ..playlists = playlists;

    return playlistSet;
  }

  @override
  Future<Singer> singer(String artistId, MusicObjectType type,
      {int offset = 0, int count = DEFAULT_REQUEST_COUNT}) {
    throw UnimplementedError();
  }

  @override
  String singerSource(String singerId) {
    return 'https://music.migu.cn/v3/music/artist/$singerId';
  }

  @override
  String songSource(String songId) {
    return "https://music.migu.cn/v3/music/song/$songId";
  }

  @override
  String userSource(String userId) {
    return "";
  }

  int _playCountFromText(String? text) {
    if (text == null) {
      return 0;
    }
    String? numStr = RegExp(r'\d+').stringMatch(text);
    if (numStr != null) {
      final num = int.tryParse(numStr);
      if (num != null && text.endsWith('万')) {
        return num * 10000;
      }
    }
    return 0;
  }

  String _playListIdFromActionUrl(String? actionUrl) {
    if (actionUrl == null) {
      return "";
    }
    final match = RegExp(r'id=([0-9]+)&').firstMatch(actionUrl);
    if (match == null) {
      return "";
    }
    return match.groupCount >= 1 ? match[1]! : "";
  }
}
