import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/song.dart';

class SongNode {
  Song song;
  SongNode prev;
  SongNode next;

  SongNode(this.song);
}

class PlayingList {
  var _playMode = PlayMode.repeat;
  var _songList = <Song>[];
  SongNode _playingHead; //当前播放列表的头结点
  SongNode _playingCurrent; //当前正在播放的歌曲对应的节点

  List<Song> generatePlayingList() {
    var list = <Song>[];
    if (_playMode == PlayMode.repeatOne) {
      var song = currentSong;
      if (song != null) {
        list.add(song);
      }
      return list;
    }
    SongNode current = _playingHead;
    while (current != null) {
      list.add(current.song);
      current = current.next;
    }
    return list;
  }

  // 替换播放列表
  void replace(List<Song> songs) {
    _refreshPlayList(songs);
  }

  void _refreshPlayList(List<Song> songs) {
    var playingList = <Song>[];
    //根据playMode排列装播放列表
    switch (_playMode) {
      case PlayMode.repeatOne:
      case PlayMode.repeat:
        playingList.addAll(songs);
        break;
      case PlayMode.random:
        playingList.addAll(List.from(songs)..shuffle());
        break;
    }

    SongNode head = new SongNode(null);
    SongNode temp = head;
    SongNode current;
    for (Song song in playingList) {
      SongNode node = new SongNode(song);
      temp.next = node;
      node.prev = temp;
      temp = node;
      if (_playingCurrent?.song == song) {
        current = node;
      }
    }
    head = head.next;
    head?.prev = null;

    _songList = List.of(songs, growable: true);
    _playingHead = head;
    _playingCurrent = current;
  }

  // 添加到下一首播放，不影响当前播放的歌曲
  void addToNext(Song song) {
    if (song == null) return;
    _songList.add(song);
    //如果当前没有播放歌曲，则将歌曲加入到链表头部
    if (_playingCurrent == null) {
      _addSongToFirst(song);
      return;
    }
    var node = SongNode(song);
    var next = _playingCurrent.next;
    _playingCurrent.next = node;
    node.prev = _playingCurrent;
    node.next = next;
    next?.prev = node;
  }

  void _addSongToFirst(Song song) {
    var node = SongNode(song);
    node.next = _playingHead;
    _playingHead?.prev = node;
    _playingHead = node;
  }

  //删除一首歌
  bool removeSong(Song song) {
    if (song == null) return false;
    var node = _findNode(song);
    if (node == null) return false;

    _songList.remove(song);

    node.next?.prev = node.prev;
    var next = node.prev?.next = node.next;

    if (song == _playingCurrent?.song) {
      _playingCurrent = next ?? _playingHead;
    }

    if (song == _playingHead?.song) {
      _playingHead = next;
      _playingHead.prev = null;
    }
  }

  //查询歌曲对应的节点
  SongNode _findNode(Song song) {
    if (song == null) {
      return null;
    }
    var current = _playingHead;
    while (current != null) {
      if (current.song == song) {
        return current;
      }
      current = current.next;
    }
    return null;
  }

  set playMode(PlayMode mode) {
    if (_playMode == mode) return;
    this._playMode = mode;
    _refreshPlayList(_songList);
  }

  Song get currentSong {
    _playingCurrent = _playingCurrent ?? _playingHead;
    return _playingCurrent ?? _playingCurrent.song;
  }

  Song get nextSong {
    if (_playingCurrent == null) {
      _playingCurrent = _playingHead;
    } else {
      if (_playMode != PlayMode.repeatOne) {
        _playingCurrent = _playingCurrent.next ?? _playingHead;
      }
    }
    return _playingCurrent?.song;
  }

  Song get prevSong {
    if (_playingCurrent == null) {
      _playingCurrent = _playingHead;
    } else {
      if (_playMode != PlayMode.repeatOne) {
        _playingCurrent = _playingCurrent.prev ?? _playingHead;
      }
    }
    return _playingCurrent?.song;
  }

  Song playNext() {
    if (_playingCurrent == null) {
      _playingCurrent = _playingHead;
    } else {
      _playingCurrent = _playingCurrent.next ?? _playingHead;
    }
    return _playingCurrent?.song;
  }

  Song playPrev() {
    if (_playingCurrent == null) {
      _playingCurrent = _playingHead;
    } else {
      _playingCurrent = _playingCurrent.prev ?? _playingHead;
    }
    return _playingCurrent?.song;
  }

  Song findSong(String plt, String id) {
    Song simpleSong = Song();
    simpleSong.plt = plt;
    simpleSong.id = id;
    return _songList.firstWhere((element) => element == simpleSong, orElse: null);
  }
}
