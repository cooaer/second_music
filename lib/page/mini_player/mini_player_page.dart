import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:second_music/entity/song.dart';
import 'package:second_music/page/mini_player/playing_list_bottom_sheet.dart';
import 'package:second_music/page/navigator.dart';
import 'package:second_music/page/play/play_logic.dart';
import 'package:second_music/res/res.dart';
import 'package:second_music/service/music_service.dart';
import 'package:second_music/widget/infinite_page_view.dart';

class MiniPlayer extends StatefulWidget {
  static const double BAR_HEIGHT = 48;
  static const double ALL_HEIGHT = 54;

  @override
  State<StatefulWidget> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  late PlaySongListLogic _logic;
  late InfinitePageController _pageController;

  @override
  void initState() {
    super.initState();
    _logic = PlaySongListLogic();
    _pageController = _logic.newPageController();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: <Widget>[
        Container(
          color: Colors.white,
          child: SafeArea(
            top: false,
            child: Container(
                height: MiniPlayer.BAR_HEIGHT,
                alignment: Alignment.topCenter,
                child: Divider(
                  height: 1,
                  color: AppColors.divider,
                )),
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            height: MiniPlayer.ALL_HEIGHT,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: _buildSongList(context),
                ),
                _buildPlayIcon(context),
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () => showPlayingList(context),
                    child: Icon(
                      Icons.playlist_play_rounded,
                      size: 36,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSongList(BuildContext context) {
    return StreamBuilder(
      initialData: MusicService().playingIndices,
      stream: MusicService().playingIndicesStream,
      builder: (context, AsyncSnapshot<List<int>> snapshot) {
        final count = snapshot.data?.length ?? 0;
        return count == 0
            ? _MiniPlayerSong(-1, null, key: Key('default_song'))
            : InfinitePageView(
                count,
                _pageController,
                (context, index, realIndex) {
                  print(
                      "MiniPlayer.buildSongList: index = $index, realIndex=$realIndex");
                  final showingListIndex = snapshot.data![realIndex];
                  final song = MusicService().showingSongList[showingListIndex];
                  return _MiniPlayerSong(realIndex, song,
                      key: Key(song.uniqueId));
                },
              );
      },
    );
  }

  Widget _buildPlayIcon(BuildContext context) {
    return StreamBuilder(
      initialData: MusicService().playing,
      stream: MusicService().playingStream,
      builder: (context, AsyncSnapshot<bool> snapshot) {
        return TextButton(
          onPressed: () => MusicService().playOrPause(),
          child: Icon(
            snapshot.data!
                ? Icons.pause_circle_outline_rounded
                : Icons.play_circle_outline_rounded,
            size: 30,
            color: AppColors.textLight,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }
}

class _MiniPlayerSong extends StatelessWidget {
  final int index;
  final Song? song;

  _MiniPlayerSong(this.index, this.song, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (index >= 0 && song != null) {
          AppNavigator().navigateTo(context, AppNavigator.play,
              params: {"index": index, "song": song}, overlay: true);
        }
      },
      child: Row(
        children: <Widget>[
          Container(
            width: MiniPlayer.BAR_HEIGHT,
            height: MiniPlayer.BAR_HEIGHT,
            alignment: Alignment.center,
            margin: EdgeInsets.only(left: 6, bottom: 6),
            decoration: BoxDecoration(
                color: AppColors.coverBg,
                borderRadius: BorderRadius.circular(24)),
            child: song != null && song!.cover.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        imageUrl: song!.cover,
                        errorWidget: (context, url, error) => SizedBox(
                              width: 44,
                              height: 44,
                            )),
                  )
                : null,
          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.only(left: 6, top: 6, right: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    song?.name ?? stringsOf(context).defaultMiniPlayerTitle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: AppColors.textTitle,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    song?.singer?.name ??
                        stringsOf(context).defaultMiniPlayerDescription,
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
