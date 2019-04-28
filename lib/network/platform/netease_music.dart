import 'dart:async';
import 'dart:isolate';

import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:second_music/model/song.dart';
import 'package:second_music/network/http_maker.dart';
import 'package:second_music/network/platform/music_provider.dart';

import '../../model/album.dart';
import '../../model/enum.dart';
import '../../model/playlist.dart';
import '../../model/playlist_set.dart';
import '../../model/search.dart';
import '../../model/singer.dart';


class NeteaseMusic extends BaseMusicProvider{

  NeteaseMusic(HttpMaker httpMaker) : super(httpMaker);

  @override
  Future<PlaylistSet> showPlayList({int offset = 0, int count = DEFAULT_REQUEST_COUNT}) async{
    String targetUrl = 'http://music.163.com/discover/playlist/?order=hot&limit=$count&offset=$offset';

    var response = await httpMaker({
      HttpMakerParams.url : targetUrl,
      HttpMakerParams.method : HttpMakerParams.methodGet,
    });
    return await asyncParseHtmlToObject(_DataObjectTags.playlistSet, response);
  }

  @override
  Future<Playlist> playList(String listId,
      {int offset = 0, int count = DEFAULT_REQUEST_COUNT}) {

    return null;
  }

  @override
  Future<Singer> singer(String artistId, MusicObjectType type,
      {int offset, int count = DEFAULT_REQUEST_COUNT}) {
    // TODO: implement artist
    return null;
  }

  @override
  Future<Album> album(String albumId, {int offset, int count = DEFAULT_REQUEST_COUNT}) {
    // TODO: implement album
    return null;
  }

  @override
  Future<bool> parseTrack(Song song) {
    // TODO: implement parseTrack
    return null;
  }

  @override
  Future<String> lyric(String songId) {
    // TODO: implement lyric
    return null;
  }


  @override
  String playlistSource(String playlistId) {

  }

  @override
  bool get showPlayListEnabled => true;

  @override
  String singerSource(String singerId) {

  }

  @override
  String albumSource(String albumId) {

  }

  @override
  String songSource(String songId) {

  }

  @override
  String userSource(String userId) {

  }

  @override
  String get platform => MusicPlatforms.NETEASE;
}

class _DataObjectTags{
  static const playlistSet = 'playlist_set';
}

Future<dynamic> asyncParseHtmlToObject(String objTag, String html)async{
  var initPort = ReceivePort();
  await Isolate.spawn(_parseHtmlEntryPoint, initPort.sendPort);
  SendPort sendPort = await initPort.first;

  var parsePort = ReceivePort();
  sendPort.send([objTag, html, parsePort.sendPort]);
  var objMap = await parsePort.first;
  switch(objTag){
    case _DataObjectTags.playlistSet:
      return _syncMapToObjOfPlaylistSet(objMap);
  }
}

PlaylistSet _syncMapToObjOfPlaylistSet(dynamic objMap){
  var playlistList = objMap['playlists'] as List;
  var playlists = playlistList?.map<Playlist>((item){
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

void _parseHtmlEntryPoint(SendPort initSendPort) async{
  var receivePort = ReceivePort();
  initSendPort.send(receivePort.sendPort);
  await for(var msg in receivePort){
    var tag = msg[0] as String;
    var html = msg[1] as String;
    var sendPort = msg[2] as SendPort;

    var dom = parse(html);
    var result;
    switch(tag){
      case _DataObjectTags.playlistSet:
        result = _syncParseDomToMapOfPlaylistSet(dom);
    }

    sendPort.send(result);
  }
}

Map<String, dynamic> _syncParseDomToMapOfPlaylistSet(Document dom){
  var playlists = <Map<String, dynamic>>[];
  dom.querySelectorAll('.m-cvrlst li').forEach((Element ele){
    var item = <String, dynamic>{};
    String url = ele.querySelector('div a').attributes['href'];
    item['id'] = Uri.parse(url).queryParameters['id'];
    item['title'] = ele.querySelector('div a').attributes['title'].trim();
    item['cover'] = ele.querySelector('img').attributes['src'];
    item['plt'] = MusicPlatforms.NETEASE;
    item['source'] = 'http://music.163.com/#/playlist?id='+item['id'];
    item['playCount'] = _playCountFromText(ele.querySelector('.nb').text);
    playlists.add(item);
  });

  var set = <String, dynamic>{};
  set['hasNext']= dom.querySelector(".znxt.js-disabled") == null;
  set['playlists']= playlists;
  return set;
}


int _playCountFromText(String text){
  String num = RegExp(r'\d+').stringMatch(text);
  if(text.endsWith('万')){
    return int.parse(num) * 10000;
  }
  return int.parse(num);
}