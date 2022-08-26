import 'dart:math' as math;
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/playing_progress.dart';
import 'package:second_music/entity/song.dart';
import 'package:second_music/page/mini_player/playing_list_bottom_sheet.dart';
import 'package:second_music/page/play/play_logic.dart';
import 'package:second_music/page/song_list/widget.dart';
import 'package:second_music/res/res.dart';
import 'package:second_music/service/music_service.dart';
import 'package:second_music/widget/infinite_page_view.dart';
import 'package:second_music/widget/play_progress_slider.dart';

class PlayPage extends StatefulWidget {
  //在可见的播放列表中的索引
  final int? index;
  final Song? song;

  PlayPage(this.index, this.song);

  @override
  State<StatefulWidget> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  @override
  void initState() {
    super.initState();
    Get.put<PlaySongListLogic>(PlaySongListLogic(
        playingIndex: widget.index, currentSong: widget.song));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topLeft,
        children: <Widget>[
          _PlayBackground(),
          SafeArea(
            child: Column(
              children: <Widget>[
                _PlayTopBar(),
                Expanded(
                  flex: 1,
                  child: _PlayCenterContainer(),
                ),
                _MiniPlayer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    Get.delete<PlaySongListLogic>();
  }
}

class _PlayBackground extends StatelessWidget {
  _PlayBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        initialData: MusicService().currentIndex,
        stream: MusicService().currentIndexStream,
        builder: (context, AsyncSnapshot<int> snapshot) {
          final cover = MusicService().currentSong?.cover;
          return _buildContent(context, cover);
        });
  }

  Widget _buildContent(BuildContext context, String? coverUrl) {
    return Container(
      color: AppColors.greyBg,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox.expand(
            child: coverUrl != null && coverUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: coverUrl,
                    fit: BoxFit.fill,
                  )
                : Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: AppColors.coverBg,
                  ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayTopBar extends StatelessWidget {
  _PlayTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: MusicService().currentIndex,
      stream: MusicService().currentIndexStream,
      builder: (context, AsyncSnapshot<int> snapshot) {
        final currentSong = MusicService().currentSong;
        return _buildContent(context, currentSong);
      },
    );
  }

  Widget _buildContent(BuildContext context, Song? song) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.transparent,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(song?.name ?? "",
              style: TextStyle(
                  color: AppColors.textEmbed,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          Text(song?.singer?.name ?? "",
              style: TextStyle(
                  color: AppColors.textEmbedHalfTransparent,
                  fontSize: 13,
                  fontWeight: FontWeight.normal))
        ],
      ),
      centerTitle: true,
      actions: [
        SizedBox(
          width: 48,
        )
      ],
    );
  }
}

class _PlayCenterContainer extends StatefulWidget {
  _PlayCenterContainer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayCenterContainerState();
}

class _PlayCenterContainerState extends State<_PlayCenterContainer> {
  late bool _isShowingCover;

  @override
  void initState() {
    super.initState();
    _isShowingCover = true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _switchPage,
        child: _isShowingCover ? _PlayCoverContainer() : _PlayLyricContainer());
  }

  void _switchPage() {
    setState(() {
      _isShowingCover = !_isShowingCover;
    });
  }
}

class _PlayCoverContainer extends StatefulWidget {
  _PlayCoverContainer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayCoverContainerState();
}

class _PlayCoverContainerState extends State<_PlayCoverContainer> {
  final _logic = Get.find<PlaySongListLogic>();
  late InfinitePageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = _logic.newPageController();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: MusicService().playingIndices,
      stream: MusicService().playingIndicesStream,
      builder: (context, AsyncSnapshot<List<int>> snapshot) {
        return StreamBuilder(
          initialData: MusicService().currentIndex,
          stream: MusicService().currentIndexStream,
          builder: (context, AsyncSnapshot<int> snapshot2) {
            return _buildContent(context, snapshot.data!, snapshot2.data!);
          },
        );
      },
    );
  }

  Widget _buildContent(
      BuildContext context, List<int> playingIndices, int currentIndex) {
    final screenWidth = MediaQuery.of(context).size.width;
    final songCount = playingIndices.length;
    final currentSong = MusicService().currentSong;
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 40),
          child: songCount == 0
              ? _PlayingSongCoverTransition("", key: Key('default_cover'))
              : InfinitePageView<Song>(
                  songCount,
                  _pageController,
                  (context, index, realIndex) {
                    final showingListIndex = playingIndices[realIndex];
                    final song =
                        MusicService().showingSongList[showingListIndex];
                    print(
                        "PlayPage.buildContent, index = $index, realIndex=$realIndex, count = $songCount");
                    return _PlayingSongCoverTransition(song.cover,
                        key: Key(song.uniqueId));
                  },
                ),
        ),
        Row(
          children: <Widget>[
            _FavorIcon(currentSong),
            Spacer(),
            Container(
              height: 80,
              width: screenWidth / 5,
              alignment: Alignment.center,
              child: IconButton(
                onPressed: () {
                  if (currentSong != null) {
                    showSongMenu(context, currentSong, null, null);
                  }
                },
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white70,
                  size: 30,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }
}

class _PlayingSongCoverTransition extends StatefulWidget {
  final String cover;

  _PlayingSongCoverTransition(this.cover, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PlayingSongCoverTransitionState();
  }
}

class _PlayingSongCoverTransitionState
    extends State<_PlayingSongCoverTransition>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(seconds: 12), vsync: this);
    animation = Tween(begin: 0.0, end: 2 * math.pi).animate(controller);
    void resetController(bool playing) {
      if (playing) {
        controller.repeat();
      } else {
        controller.stop();
      }
    }

    MusicService().playingStream.listen((playing) {
      resetController(playing);
    });
    resetController(MusicService().playing);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        child: _PlayingSongCover(cover: widget.cover),
        animation: animation,
        builder: (context, child) => Transform.rotate(
              angle: animation.value,
              child: child,
            ));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class _PlayingSongCover extends StatelessWidget {
  const _PlayingSongCover({
    Key? key,
    required this.cover,
  }) : super(key: key);

  final String cover;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Container(
        width: 252,
        height: 252,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white54,
          borderRadius: BorderRadius.circular(126),
        ),
        child: cover.isEmpty
            ? Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(120)),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(120),
                child: CachedNetworkImage(
                  imageUrl: cover,
                  width: 240,
                  height: 240,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }
}

class _FavorIcon extends StatefulWidget {
  final Song? currentSong;

  _FavorIcon(this.currentSong, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FavorIconState();
  }
}

class _FavorIconState extends State<_FavorIcon> {
  SongLogic? _songLogic;

  @override
  void initState() {
    super.initState();
    if (widget.currentSong != null) {
      _songLogic = SongLogic(widget.currentSong!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_songLogic == null) {
      return _buildFavorIcon(context, null, false);
    } else {
      return StreamBuilder(
        initialData: false,
        stream: _songLogic!.isFavoriteStream,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          return _buildFavorIcon(
              context, _songLogic!.toggleFavorite, snapshot.data!);
        },
      );
    }
  }

  Widget _buildFavorIcon(
      BuildContext context, GestureTapCallback? tapCallback, bool isFavorite) {
    return Container(
      height: 80,
      width: MediaQuery.of(context).size.width / 5,
      alignment: Alignment.center,
      child: IconButton(
        onPressed: tapCallback,
        icon: Icon(
          AppImages.favorIcon(isFavorite),
          color: Colors.white70,
          size: 30,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _songLogic?.dispose();
  }
}

class _PlayLyricContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: Text(
          '暂不支持显示歌词',
          style: TextStyle(color: AppColors.textEmbed),
        ));
  }
}

class _MiniPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          StreamBuilder(
              initialData: MusicService().playingProgress,
              stream: MusicService().playingProgressStream,
              builder: (context, AsyncSnapshot<PlayingProgress> snapshot) {
                return _buildPlayProgress(
                    context, snapshot.data!.position, snapshot.data!.duration);
              }),
          Row(
            children: <Widget>[
              StreamBuilder(
                initialData: MusicService().playMode,
                stream: MusicService().playModeStream,
                builder: (context, AsyncSnapshot<PlayMode> snapshot) {
                  return _buildMiniPlayerIcon(context, 'play_mode',
                      AppImages.playModeIcon(snapshot.data!), 32);
                },
              ),
              _buildMiniPlayerIcon(
                  context, 'play_pre', Icons.skip_previous_rounded, 40),
              StreamBuilder(
                initialData: MusicService().playing,
                stream: MusicService().playingStream,
                builder: (context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.data == true) {
                    return _buildMiniPlayerIcon(context, 'playOrPause',
                        Icons.pause_circle_filled_rounded, 70);
                  } else {
                    return _buildMiniPlayerIcon(context, 'playOrPause',
                        Icons.play_circle_filled_rounded, 70);
                  }
                },
              ),
              _buildMiniPlayerIcon(
                  context, 'play_next', Icons.skip_next_rounded, 40),
              _buildMiniPlayerIcon(
                  context, 'playing_list', Icons.playlist_play_rounded, 40),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPlayProgress(BuildContext context, int position, int duration) {
    // duration = math.max(position, duration);
    // debugPrint("buildPlayProgress: position = $position, duration = $duration");
    return Row(
      children: <Widget>[
        SizedBox(
          width: 20,
        ),
        Text(
          stringsOf(context).playPosition(position),
          style: TextStyle(fontSize: 10, color: Colors.white30),
        ),
        Expanded(
            flex: 1,
            child: PlayProgressSlider(position, duration,
                (value) => MusicService().seekTo(value.toInt()))),
        Text(
          stringsOf(context).playPosition(duration),
          style: TextStyle(fontSize: 10, color: Colors.white30),
        ),
        SizedBox(
          width: 20,
        ),
      ],
    );
  }

  Widget _buildMiniPlayerIcon(
      BuildContext context, String tag, IconData icon, double iconSize) {
    return Expanded(
      flex: 1,
      child: Container(
        height: 80,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () => _onTapControlIcon(context, tag),
          child: Icon(
            icon,
            color: Colors.white70,
            size: iconSize,
          ),
        ),
      ),
    );
  }

  void _onTapControlIcon(BuildContext context, String iconName) {
    switch (iconName) {
      case 'play_mode':
        MusicService().switchPlayMode();
        break;
      case 'play_pre':
        MusicService().playPrev();
        break;
      case 'playOrPause':
        MusicService().playOrPause();
        break;
      case 'play_next':
        MusicService().playNext();
        break;
      case 'playing_list':
        showPlayingList(context);
        break;
    }
  }
}
