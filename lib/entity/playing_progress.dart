import 'package:second_music/player/music_messages.dart';

class PlayingProgress{
  int position;
  int duration;

  PlayingProgress(this.position, this.duration);

  PlayingProgress.fromMessage(PositionMessage message){
    this.duration = message.duration;
    this.position = message.position;
  }

}