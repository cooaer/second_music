import 'package:flutter/painting.dart';
import 'package:second_music/entity/album.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/singer.dart';
import 'package:second_music/entity/song.dart';

class SingerState {
  final MusicPlatform plt;
  final String singerId;
  Singer? singer;

  SingerState(this.plt, this.singerId, {this.singer});

  void setSinger(Singer singer) {
    this.singer = singer;
  }

  int _songTotal = -1;
  List<Song> _songs = [];
  List<Song> get songs => _songs;

  void addSongs(int total, List<Song> songs) {
    this._songTotal = total;
    this._songs.addAll(songs);
  }

  bool get hasMoreSongs => _songTotal < 0 || _songTotal > _songs.length;

  bool isLoadingSongs = true;

  int _albumTotal = -1;
  List<Album> _albums = [];
  List<Album> get albums => _albums;

  void addAlbums(total, List<Album> albums) {
    this._albumTotal = total;
    this._albums.addAll(albums);
  }

  bool get hasMoreAlbums => _albumTotal < 0 || _albumTotal > _albums.length;

  bool isLoadingAlbums = false;

  var topBarColor = Color(0xff8f8f8f);

  Color get transparentTopBarColor => topBarColor.withAlpha(0);
}
