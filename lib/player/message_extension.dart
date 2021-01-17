import 'package:second_music/entity/song.dart';
import 'package:second_music/player/music_messages.dart';

extension SongsExtension on List<Song> {
  SongsMessage toMessage() {
    var message = new SongsMessage();
    message.songs = <Map<String, Object>>[];
    for (var song in this) {
      message.songs.add(song.toMap());
    }
    return message;
  }
}

extension SongsMessageExtension on SongsMessage {
  List<Song> toSongs() {
    var songs = <Song>[];
    for (var obj in this.songs) {
      if (obj is Map) {
        songs.add(Song.fromMap(obj));
      }
    }
    return songs;
  }
}
