import 'package:get/get.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/singer.dart';
import 'package:second_music/repository/remote/platform/music_provider.dart';
import 'package:second_music/util/ColorMeter.dart';

import 'singer_state.dart';

class SingerLogic extends GetxController {
  final SingerState state;
  final ColorMeter colorMeter = ColorMeter();

  SingerLogic(MusicPlatform plt, String singerId, Singer? singer)
      : this.state = SingerState(plt, singerId, singer: singer);

  @override
  void onReady() async {
    super.onReady();
    _fetchSingerSongs();
  }

  void _fetchSingerSongs() async {
    state.isLoadingSongs = true;
    update();
    final singer = await MusicProvider(state.plt).singerSongs(state.singerId);
    state.isLoadingSongs = false;
    if (singer != null) {
      state.setSinger(singer);
      state.addSongs(singer.songTotal, singer.songs);
      updateTopBarBackgroundColor(singer.avatar);
    }
    update();
  }

  void updateTopBarBackgroundColor(String avatarUrl) async {
    state.topBarColor = await colorMeter.generateTopBarColor(avatarUrl);
    update();
  }

  void requestHotAlbums() async {
    state.isLoadingAlbums = true;
    update();
    final singer = await MusicProvider(state.plt).singerAlbums(state.singerId);
    state.isLoadingAlbums = false;
    if (singer != null) {
      state.addAlbums(singer.albumTotal, singer.albums);
    }
    update();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
