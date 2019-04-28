import 'dart:math' as math;
import 'dart:ui';

import 'package:after_layout/after_layout.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:second_music/model/enum.dart';
import 'package:second_music/model/song.dart';
import 'package:second_music/page/model.dart';
import 'package:second_music/page/play/model.dart';
import 'package:second_music/page/play_control/widget.dart';
import 'package:second_music/res/res.dart';
import 'package:second_music/widget/material_icon_round.dart';

class PlayPage extends StatefulWidget {

  final Song song;

  PlayPage(this.song);

  @override
  State<StatefulWidget> createState() => _PlayPageState();

}

class _PlayPageState extends State<PlayPage> with AfterLayoutMixin{

  @override
  void initState() {
    super.initState();
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
                _PlayControl(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if(widget.song != null){
      PlayControlModel.instance.playSongNow(widget.song);
    }
  }

}



class _PlayBackground extends StatelessWidget {
  _PlayBackground({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        initialData: PlayControlModel.instance.currentSong,
        stream: PlayControlModel.instance.currentSongStream,
        builder: (context, AsyncSnapshot<Song> snapshot) {
          return _buildContent(context, snapshot.data?.cover);
        });
  }

  Widget _buildContent(BuildContext context, String coverUrl) {
    return Container(
      color: AppColors.grey_bg,
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
                    color: AppColors.cover_bg,
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
  _PlayTopBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: PlayControlModel.instance.currentSong,
      stream: PlayControlModel.instance.currentSongStream,
      builder: (context, AsyncSnapshot<Song> snapshot) {
        return _buildContent(context, snapshot.data);
      },
    );
  }

  Widget _buildContent(BuildContext context, Song song) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.transparent,
      title: GestureDetector(
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(song?.name ?? '',
                style: TextStyle(
                    color: AppColors.text_embed, fontSize: 16, fontWeight: FontWeight.w600)),
            Text(song?.singer?.name ?? '',
                style: TextStyle(
                    color: AppColors.text_embed_half_transparent,
                    fontSize: 13,
                    fontWeight: FontWeight.normal))
          ],
        ),
      ),
      centerTitle: true,
    );
  }
}

class _PlayCenterContainer extends StatefulWidget {
  _PlayCenterContainer({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayCenterContainerState();
}

class _PlayCenterContainerState extends State<_PlayCenterContainer> {
  bool _isShowingCover;

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
      child: _isShowingCover ? _PlayCoverContainer() : _PlayLyricContainer(),
    );
  }

  void _switchPage() {
    setState(() {
      _isShowingCover = !_isShowingCover;
    });
  }
}

class _PlayCoverContainer extends StatefulWidget {
  _PlayCoverContainer({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayCoverContainerState();
}

class _PlayCoverContainerState extends State<_PlayCoverContainer> {
  SongControllerModel _songControllerModel;

  @override
  void initState() {
    super.initState();
    _songControllerModel = SongControllerModel();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: PlayControlModel.instance.playingList,
      stream: PlayControlModel.instance.playingListStream,
      builder: (context, AsyncSnapshot<List<Song>> snapshot) {
        return StreamBuilder(
          initialData: PlayControlModel.instance.currentSong,
          stream: PlayControlModel.instance.currentSongStream,
          builder: (context, AsyncSnapshot<Song> snapshot2) {
            return _buildContent(context, snapshot.data, snapshot2.data);
          },
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, List<Song> songs, Song currentSong) {
    var screenWidth = MediaQuery.of(context).size.width;
    var songCount = songs.length;
    var songModel = SongModel(currentSong);
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 40),
          child: songCount == 0
              ? _PlayingSongCover(null, key: Key('default_cover'))
              : NotificationListener<ScrollEndNotification>(
                  onNotification: _handleSongListScrollEndNotification,
                  child: PageView.builder(
                    itemCount: double.maxFinite.floor(),
                    controller: _songControllerModel.newSongPageController(),
                    itemBuilder: (context, index) {
                      var realIndex = SongControllerModel.realIndexOf(index);
                      var cover = songs[realIndex].cover;
                      return _PlayingSongCover(cover, key: Key(cover));
                    },
                  ),
                ),
        ),
        Row(
          children: <Widget>[
            StreamBuilder(
              initialData: false,
              stream: songModel.isFavoriteStream,
              builder: (context, AsyncSnapshot<bool> snapshot) {
                return _buildFavorIcon(context, songModel, snapshot.data);
              },
            ),
            Spacer(),
            Container(
              height: 80,
              width: screenWidth / 5,
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {},
                child: MdrIcon(
                  'more_vert',
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

  bool _handleSongListScrollEndNotification(ScrollEndNotification notification) {
    int index = _songControllerModel.currentPageController.page.round();
    var realIndex = SongControllerModel.realIndexOf(index);
    PlayControlModel.instance.playIndexWithoutAnimation(realIndex, withoutModel: _songControllerModel);
  }

  Widget _buildFavorIcon(BuildContext context, SongModel songModel, bool isFavorite) {
    return Container(
      height: 80,
      width: MediaQuery.of(context).size.width / 5,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: songModel.toggleFavorite,
        child: MdrIcon(
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
    _songControllerModel.dispose();
  }
}

class _PlayingSongCover extends StatelessWidget {
  final String cover;

  _PlayingSongCover(this.cover, {Key key}) : super(key: key);

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
        child: cover == null || cover.isEmpty
            ? Container(
                width: 240,
                height: 240,
                decoration:
                    BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(120)),
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

class _PlayLyricContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
    );
  }
}

class _PlayControl extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          StreamBuilder(
              initialData: PlayControlModel.instance.currentDuration,
              stream: PlayControlModel.instance.currentDurationStream,
              builder: (context, AsyncSnapshot<int> snapshotDuration) {
                return StreamBuilder(
                  initialData: PlayControlModel.instance.currentPosition,
                  stream: PlayControlModel.instance.currentPositionStream,
                  builder: (context, AsyncSnapshot<int> snapshotPosition) {
                    return _buildPlayProgress(
                        context, snapshotPosition.data, snapshotDuration.data);
                  },
                );
              }),
          Row(
            children: <Widget>[
              StreamBuilder(
                initialData: PlayControlModel.instance.playMode,
                stream: PlayControlModel.instance.playModeStream,
                builder: (context, AsyncSnapshot<PlayMode> snapshot) {
                  return _buildPlayControlIcon(
                      context, 'play_mode', AppImages.playModeIcon(snapshot.data), 32);
                },
              ),
              _buildPlayControlIcon(context, 'play_pre', 'skip_previous', 40),
              StreamBuilder(
                initialData: PlayControlModel.instance.playerState,
                stream: PlayControlModel.instance.playerStateStream,
                builder: (context, AsyncSnapshot<AudioPlayerState> snapshot) {
                  if (snapshot.data == AudioPlayerState.PLAYING) {
                    return _buildPlayControlIcon(context, 'playOrPause', 'pause_circle_filled', 70);
                  } else {
                    return _buildPlayControlIcon(context, 'playOrPause', 'play_circle_filled', 70);
                  }
                },
              ),
              _buildPlayControlIcon(context, 'play_next', 'skip_next', 40),
              _buildPlayControlIcon(context, 'playing_list', 'playlist_play', 40),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPlayProgress(BuildContext context, int position, int duration) {
    var maxDuration = math.max(position, duration);
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
          child: Slider(
            value: position.toDouble(),
            activeColor: Color(0x3fffffff),
            inactiveColor: Color(0x7fffffff),
            min: 0,
            max: maxDuration.toDouble(),
            onChanged: (value) {
              PlayControlModel.instance.seekTo(value.round());
            },
          ),
        ),
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

  Widget _buildPlayControlIcon(BuildContext context, String tag, String iconName, double iconSize) {
    return Expanded(
      flex: 1,
      child: Container(
        height: 80,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () => _onTapControlIcon(context, tag),
          child: MdrIcon(
            iconName,
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
        PlayControlModel.instance.switchPlayMode();
        break;
      case 'play_pre':
        PlayControlModel.instance.playPre();
        break;
      case 'playOrPause':
        PlayControlModel.instance.playOrPause();
        break;
      case 'play_next':
        PlayControlModel.instance.playNext();
        break;
      case 'playing_list':
        showPlayingList(context);
        break;
    }
  }
}
