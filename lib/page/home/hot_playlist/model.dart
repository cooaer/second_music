import 'dart:async';

import 'package:second_music/model/playlist_set.dart';
import 'package:second_music/network/platform/music_provider.dart';

class HotPlaylistModel {
  final String plt;

  MusicProvider _provider;

  PlaylistSet _set = PlaylistSet();
  bool _loading = false;

  bool get loading => _loading;
  bool _lastError = false;

  bool get lastError => _lastError;

  var _playlistSetController = StreamController<PlaylistSet>.broadcast();
  var _loadingController = StreamController<bool>.broadcast();
  var _lastErrorController = StreamController<bool>.broadcast();

  Stream<PlaylistSet> get playlistSetStream => _playlistSetController.stream.map((item) {
    _set.hasNext = item.hasNext;
    _set.playlists.addAll(item.playlists);
    return _set;
  });

  Stream<bool> get loadingStream => _loadingController.stream.map((item) {
    _loading = item;
    return _loading;
  });

  Stream<bool> get lastErrorStream => _lastErrorController.stream.map((item) {
    _lastError = item;
    return _lastError;
  });

  HotPlaylistModel(this.plt) : _provider = MusicProvider(plt);

  Future refresh() {
    return _request(true);
  }

  /// 请求更多的歌单
  Future requestMore(bool force) {
    if (_lastError && !force) return null;
    return _request(false);
  }

  Future _request(bool clear) async {
    if (_loading) return null;
    _loading = true;
    _loadingController.add(true);

    var newSet = await _provider.showPlayList(offset: clear ? 0 : _set.playlists.length);
    if (newSet != null && newSet.playlists != null) {
      if (clear) _set.playlists.clear();
      _playlistSetController.add(newSet);
      _lastErrorController.add(false);
    } else {
      _lastErrorController.add(true);
    }
    _loading = false;
    _loadingController.add(false);
  }

  void dispose() {
    _playlistSetController.close();
    _loadingController.close();
    _lastErrorController.close();
  }
}
