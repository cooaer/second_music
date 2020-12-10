flutter pub run pigeon \
  --input pigeons/music_player_messages.dart \
  --dart_out ./lib/player/music_messages.dart \
  --objc_header_out  ios/Runner/MusicMessages.h \
  --objc_source_out ios/Runner/MusicMessages.m \
  --objc_prefix FLT \
  --java_out android/app/src/main/java/app/dier/music/MusicMessages.java\
  --java_package app.dier.music