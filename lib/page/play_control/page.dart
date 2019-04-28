import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:second_music/model/song.dart';
import 'package:second_music/page/model.dart';
import 'package:second_music/page/navigator.dart';
import 'package:second_music/page/play/model.dart';
import 'package:second_music/page/play_control/widget.dart';
import 'package:second_music/res/res.dart';
import 'package:second_music/widget/material_icon_round.dart';

class PlayController extends StatefulWidget {
  static const double BAR_HEIGHT = 48;
  static const double ALL_HEIGHT = 54;

  @override
  State<StatefulWidget> createState() => _PlayControllerState();
}

class _PlayControllerState extends State<PlayController> {
  SongControllerModel _songControllerModel;

  @override
  void initState() {
    super.initState();
    _songControllerModel = SongControllerModel();
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
                height: PlayController.BAR_HEIGHT,
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
            height: 54,
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
                  child: FlatButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => showPlayingList(context),
                    shape: CircleBorder(),
                    child: MdrIcon(
                      'playlist_play',
                      size: 36,
                      color: AppColors.text_light,
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
      initialData: PlayControlModel.instance.playingList,
      stream: PlayControlModel.instance.playingListStream,
      builder: (context, AsyncSnapshot<List<Song>> snapshot) {
        var count = snapshot.data.length;
        return count == 0
            ? _PlayControllerSong(null, key: Key('default_song'))
            : NotificationListener<ScrollEndNotification>(
                onNotification: _handleSongListScrollEndNotification,
                child: PageView.builder(
                  controller: _songControllerModel.newSongPageController(),
                  itemCount: double.maxFinite.floor(),
                  itemBuilder: (context, index) {
                    var realIndex = SongControllerModel.realIndexOf(index);
                    var song = snapshot.data[realIndex];
                    return _PlayControllerSong(song, key: Key(song.plt + song.id));
                  },
                ),
              );
      },
    );
  }

  bool _handleSongListScrollEndNotification(ScrollEndNotification notification){
    int index = _songControllerModel.currentPageController.page.round();
    var realIndex = SongControllerModel.realIndexOf(index);
    PlayControlModel.instance.playIndexWithoutAnimation(realIndex, withoutModel: _songControllerModel);
    return true;
  }

  Widget _buildPlayIcon(BuildContext context) {
    return StreamBuilder(
      initialData: PlayControlModel.instance.playerState,
      stream: PlayControlModel.instance.playerStateStream,
      builder: (context, AsyncSnapshot<AudioPlayerState> snapshot) {
        return Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: FlatButton(
            padding: EdgeInsets.zero,
            onPressed: () => PlayControlModel.instance.playOrPause(),
            shape: CircleBorder(),
            child: MdrIcon(
              AppImages.playIcon(snapshot.data),
              size: 30,
              color: AppColors.text_light,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _songControllerModel.dispose();
  }
}

class _PlayControllerSong extends StatelessWidget {
  final Song song;

  _PlayControllerSong(this.song, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        PlayControlModel.instance.play();
        AppNavigator.instance.navigateTo(context, AppNavigator.play, overlay: true);
      },
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            margin: EdgeInsets.only(left: 6, bottom: 6),
            decoration:
                BoxDecoration(color: AppColors.cover_bg, borderRadius: BorderRadius.circular(24)),
            child: song?.cover != null && song.cover.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                        width: 44, height: 44, fit: BoxFit.cover, imageUrl: song.cover),
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
                    song?.name ?? stringsOf(context).defaultPlayControlTitle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: AppColors.text_title,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    song?.singer?.name ?? stringsOf(context).defaultPlayControlDescription,
                    style: TextStyle(
                      color: AppColors.text_light,
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
