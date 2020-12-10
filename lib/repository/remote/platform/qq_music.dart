import 'dart:convert';
import 'dart:math';

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
  Future<PlaylistSet> showPlayList(
      {int offset = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    final target_url =
        'https://c.y.qq.com/splcloud/fcgi-bin/fcg_get_diss_by_tag.fcg'
        '?picmid=1&rnd=${Random().nextDouble()}&g_tk=732560869'
        '&loginUin=0&hostUin=0&format=json&inCharset=utf8&outCharset=utf-8'
        '&notice=0&platform=yqq.json&needNewCode=0'
        '&categoryId=10000000&sortId=5&sin=$offset&ein=${19 + offset}';
    final response = await httpMaker({
      HttpMakerParams.url: target_url,
      HttpMakerParams.method: HttpMakerParams.methodGet,
    });

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
  Future<bool> parseTrack(Song song) async {
    final url = 'https://u.y.qq.com/cgi-bin/musicu.fcg?loginUin=0&'
        'hostUin=0&format=json&inCharset=utf8&outCharset=utf-8&notice=0&'
        'platform=yqq.json&needNewCode=0&data=%7B%22req_0%22%3A%7B%22'
        'module%22%3A%22vkey.GetVkeyServer%22%2C%22method%22%3A%22'
        'CgiGetVkey%22%2C%22param%22%3A%7B%22guid%22%3A%2210000%22%2C%22songmid%22%3A%5B%22'
        '${song.pltId}%22%5D%2C%22songtype%22%3A%5B0%5D%2C%22uin%22%3A%220%22%2C%22loginflag%22'
        '%3A1%2C%22platform%22%3A%2220%22%7D%7D%2C%22comm%22%3A%7B%22uin%22%3A0%2C%22'
        'format%22%3A%22json%22%2C%22ct%22%3A20%2C%22cv%22%3A0%7D%7D';

    final response = await httpMaker({
      HttpMakerParams.url: url,
      HttpMakerParams.method: HttpMakerParams.methodGet
    });
    final respJson = json.decode(response);
    if (respJson == null) return false;
    song.streamUrl = respJson['req_0']['data']['sip'].first +
        respJson['req_0']['data']['midurlinfo'].first['purl'];
    return true;
  }

  @override
  Future<Album> album(String albumId,
      {int offset = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    final url = 'http://i.y.qq.com/v8/fcg-bin/fcg_v8_album_info_cp.fcg?'
        'platform=h5page&albummid=$albumId&g_tk=938407465&uin=0&'
        'format=jsonp&inCharset=utf-8&outCharset=utf-8&notice=0&'
        'platform=h5&needNewCode=1&_=1459961045571&'
        'jsonpCallback=asonglist1459961045566';

    final result = await httpMaker({
      HttpMakerParams.url: url,
      HttpMakerParams.method: HttpMakerParams.methodGet
    });
    final jsonStr = result.substring(
        ' asonglist1459961045566('.length, result.length - ')'.length);
    final jsonMap = json.decode(jsonStr);
    final dataJson = Json.getMap(jsonMap, 'data');
    final listJson = Json.getList(dataJson, 'list');

    final songs =
        await Future.wait(listJson.map((item) => _convertSong2(item)));

    final singer = Singer()
      ..plt = MusicPlatform.qq
      ..id = Json.getString(dataJson, 'singermid')
      ..name = Json.getString(dataJson, 'singername');

    final album = Album()
      ..plt = MusicPlatform.qq
      ..id = Json.getString(dataJson, 'mid')
      ..name = Json.getString(dataJson, 'name')
      ..cover = _getImageUrl(Json.getString(dataJson, 'mid'), 'album')
      ..releaseTime = Json.getString(dataJson, 'aDate')
      ..description = Json.getString(dataJson, 'desc')
      ..singers = [singer]
      ..songTotal = Json.getInt(dataJson, 'total')
      ..songs = songs;

    return album;
  }

  @override
  Future<Singer> singer(String artistId, MusicObjectType type,
      {int offset = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    //TODO implement
    return Singer();
  }

  @override
  Future<Playlist> playList(String listId,
      {int offset = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    final targetUrl =
        'https://c.y.qq.com/qzone/fcg-bin/fcg_ucc_getcdinfo_byids_cp.fcg?'
        'type=1&json=1&utf8=1&onlysong=0&new_format=1&disstid=$listId&g_tk=1062527372&'
        '&loginUin=1064549797hostUin=0&format=json&inCharset=utf8&outCharset=utf-8&notice=0&'
        'platform=yqq.json&needNewCode=0';

    String response = await httpMaker({'url': targetUrl, 'method': 'get'});
    final jsonString =
        response.substring('jsonCallback('.length, response.lastIndexOf(')'));
    Map<String, dynamic> data = json.decode(jsonString);
    Map<String, dynamic> dataCdlist0 = Json.getList(data, 'cdlist').first;

    final creator = User();
    creator.plt = MusicPlatform.qq;
    creator.id = Json.getString(dataCdlist0, 'uin');
    creator.name =
        App.htmlUnescape.convert(Json.getString(dataCdlist0, 'nick'));
    creator.avatar = Json.getString(dataCdlist0, 'headurl');
    creator.source = 'https://y.qq.com/portal/profile.html?uin=${creator.id}';

    final listJson = Json.getList(dataCdlist0, 'songlist');
    final songList = await Future.wait(listJson.map((e) => _convertSong(e)));

    final playlist = Playlist();
    playlist.id = listId;
    playlist.plt = MusicPlatform.qq;
    playlist.title =
        App.htmlUnescape.convert(Json.getString(dataCdlist0, 'dissname'));
    playlist.cover = Json.getString(dataCdlist0, 'logo');
    playlist.description = Json.getString(dataCdlist0, 'desc');
    playlist.source = 'https://y.qq.com/n/yqq/playlist/$listId.html';
    playlist.playCount = Json.getInt(dataCdlist0, 'visitnum');
    playlist.creator = creator;

    playlist.songTotal = Json.getInt(dataCdlist0, 'songnum');
    playlist.songs = songList;
    return playlist;
  }

  @override
  Future<SearchResult> searchPlaylists(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    final enKeyword = Uri.encodeComponent(keyword);
    final searchId = (Random().nextDouble() * 9655).floor().toString();

    // page 从1开始
    final url = 'https://c.y.qq.com/soso/fcgi-bin/client_music_search_songlist?'
        'page_no=$page&query=$enKeyword&format=json&outCharset=utf-8&inCharset=utf-8&'
        'num_per_page=$count&searchid=$searchId&remoteplace=txt.mac.search';

    final response = await httpMaker({
      HttpMakerParams.url: url,
      HttpMakerParams.method: HttpMakerParams.methodGet
    });

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
  Future<SearchResult> searchSongs(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) {
    return _searchCpInternal(keyword, 0, 0, page: page, count: count);
  }

  @override
  Future<SearchResult> searchAlbums(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) {
    return _searchCpInternal(keyword, 8, 0, page: page, count: count);
  }

  @override
  Future<SearchResult> searchSingers(String keyword,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) {
    return _searchCpInternal(keyword, 0, 1, page: page, count: count);
  }

  /// 搜索歌曲、专辑、歌手，
  /// type=0:歌曲，type=8:专辑，
  /// catZhida=1，返回歌手信息
  Future<SearchResult> _searchCpInternal(String keyword, int type, int catZhida,
      {int page = 0, int count = DEFAULT_REQUEST_COUNT}) async {
    final enKeyword = Uri.encodeComponent(keyword);
    final searchId = (Random().nextDouble() * 9655).floor().toString();

    final url =
        'https://c.y.qq.com/soso/fcgi-bin/client_search_cp?remoteplace=txt.yqq.center&'
        'searchid=$searchId&t=$type&p=$page&n=$count&w=$enKeyword&catZhida=$catZhida&'
        'format=json&inCharset=utf8&outCharset=utf-8&platform=yqq.json';

    final response = await httpMaker({
      HttpMakerParams.url: url,
      HttpMakerParams.method: HttpMakerParams.methodGet
    });

    final respJson = json.decode(response);
    final dataJson = Json.getMap(respJson, 'data');

    final result = SearchResult();

    if (dataJson.containsKey('zhida')) {
      final zhidaJson = Json.getMap(dataJson, 'zhida');
      if (zhidaJson.containsKey('zhida_singer')) {
        final singerJson = Json.getMap(zhidaJson, 'zhida_singer');
        final singer = _convertSinger(singerJson);
        result.total = 1;
        result.items = [singer];
        return result;
      }
    }

    if (dataJson.containsKey('song')) {
      final songJson = Json.getMap(dataJson, 'song');
      final listJson = Json.getList(songJson, 'list');
      final songs = await Future.wait(listJson.map((e) => _convertSong2(e)));

      result.total = Json.getInt(songJson, 'totalnum');
      result.items = songs;
      return result;
    }

    if (dataJson.containsKey('album')) {
      final albumJson = Json.getMap(dataJson, 'album');
      final listJson = Json.getList(albumJson, 'list');
      result.total = Json.getInt(albumJson, 'totalnum');
      result.items = listJson.map((item) => _convertAlbum(item)).toList();
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

  Future<Song> _convertSong(Map<String, dynamic> songJson) async {
    // debugPrint("qq.convertSong, json = $songJson");
    final singerListJson = Json.getList(songJson, 'singer');
    final singerList = singerListJson.map((item) {
      final singer = Singer()
        ..plt = MusicPlatform.qq
        ..id = Json.getString(item, 'mid')
        ..name = Json.getString(item, 'name');
      return singer;
    }).toList();

    final albumJson = Json.getMap(songJson, 'album');
    final album = Album()
      ..plt = MusicPlatform.qq
      ..id = Json.getString(albumJson, 'mid')
      ..name = Json.getString(albumJson, 'name')
      ..subtitle = Json.getString(albumJson, 'subtitle');

    final song = Song()
      ..plt = MusicPlatform.qq
      ..pltId = Json.getString(songJson, 'mid')
      ..name = Json.getString(songJson, 'name')
      ..subtitle = Json.getString(songJson, 'subtitle')
      ..cover = _getImageUrl(album.id, 'album')
      ..singers = singerList
      ..album = album;

    await parseTrack(song);

    return song;
  }

  Future<Song> _convertSong2(Map<String, dynamic> songJson) async {
    // debugPrint("qq.convertSong2, json = $songJson");
    final singerListJson = Json.getList(songJson, 'singer');
    final singerList = singerListJson.map((item) {
      final singer = Singer()
        ..plt = MusicPlatform.qq
        ..id = Json.getString(item, 'mid')
        ..name = Json.getString(item, 'name');
      return singer;
    }).toList();

    final album = Album()
      ..plt = MusicPlatform.qq
      ..id = Json.getString(songJson, 'albummid')
      ..name = Json.getString(songJson, 'albumname');

    final song = Song()
      ..plt = MusicPlatform.qq
      ..pltId = Json.getString(songJson, 'songmid')
      ..name = Json.getString(songJson, 'songname')
      ..subtitle = Json.getString(songJson, 'lyric')
      ..cover = _getImageUrl(album.id, 'album')
      ..singers = singerList
      ..album = album;

    await parseTrack(song);

    return song;
  }

  Album _convertAlbum(Map<String, dynamic> json) {
    final singerJson = Json.getList(json, 'singer_list');
    final singers = singerJson.map((item) {
      final singer = Singer()
        ..plt = MusicPlatform.qq
        ..id = Json.getString(item, 'mid')
        ..name = Json.getString(item, 'name');
      return singer;
    }).toList();

    return Album()
      ..plt = MusicPlatform.qq
      ..id = Json.getString(json, 'albumMID')
      ..name = Json.getString(json, 'albumName')
      ..cover = Json.getString(json, 'albumPic')
      ..releaseTime = Json.getString(json, 'publicTime')
      ..singers = singers
      ..songTotal = Json.getInt(json, 'song_count');
  }

  Singer _convertSinger(Map<String, dynamic> json) {
    final albumsJson = Json.getList(json, 'hotalbum');
    final albums = albumsJson.map((item) {
      return Album()
        ..plt = platform
        ..id = Json.getString(item, 'albumMID')
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
      ..id = Json.getString(json, 'singerID')
      ..name = Json.getString(json, 'singerName')
      ..avatar = Json.getString(json, 'singerPic')
      ..albumTotal = Json.getInt(json, 'albumNum')
      ..albums = albums
      ..songTotal = Json.getInt(json, 'songNum')
      ..songs = songs;
  }

  Playlist _convertPlaylist(Map<String, dynamic> json) {
    final creatorJson = Json.getMap(json, 'creator');
    final creator = User()
      ..plt = MusicPlatform.qq
      ..source =
          'https://y.qq.com/portal/profile.html?uin=${Json.getString(creatorJson, 'encrypt_uin')}'
      ..id = Json.getString(creatorJson, 'encrypt_uin')
      ..name = App.htmlUnescape.convert(Json.getString(creatorJson, 'name'))
      ..avatar = Json.getString(creatorJson, 'avatarUrl');

    return Playlist()
      ..plt = MusicPlatform.qq
      ..id = Json.getString(json, 'dissid')
      ..title = App.htmlUnescape.convert(Json.getString(json, 'dissname'))
      ..cover = Json.getString(json, 'imgurl')
      ..playCount = Json.getInt(json, 'listennum')
      ..description = Json.getString(json, 'introduction')
      ..creator = creator
      ..songTotal = Json.getInt(json, 'song_count');
  }

  String _getImageUrl(String imageId, String imageType) {
    if (imageId.isEmpty) {
      return '';
    }
    var category = '';
    if (imageType == 'artist') {
      category = 'mid_singer_300';
    }
    if (imageType == 'album') {
      category = 'mid_album_300';
    }

    final params =
        '$category/${imageId.substring(imageId.length - 2, imageId.length - 1)}/${imageId.substring(imageId.length - 1)}/$imageId';
    final url = 'http://imgcache.qq.com/music/photo/${params}.jpg';
    return url;
  }
}
