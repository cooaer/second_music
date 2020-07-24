import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:second_music/model/song_list.dart';
import 'package:second_music/page/home/my_song_list/model.dart';
import 'package:second_music/page/home/my_song_list/widget.dart';
import 'package:second_music/page/navigator.dart';
import 'package:second_music/res/res.dart';
import 'package:second_music/widget/material_icon_round.dart';

class HomeMySongList extends StatefulWidget {
  @override
  State createState() {
    return HomeMySongListState();
  }
}

class HomeMySongListState extends State with AutomaticKeepAliveClientMixin {
  MySongListModel _model;

  @override
  void initState() {
    super.initState();
    _model = MySongListModel.instance;
    _model.refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder(
      stream: MySongListModel.instance.mySongListStream,
      builder: (context, AsyncSnapshot<List<SongList>> snapshot) {
        return _buildContent(context, snapshot.data);
      },
    );
  }

  Widget _buildContent(BuildContext context, List<SongList> songLists) {
    var createdPlaylists = MySongListModel.createdOfPlaylist(songLists);
    var collectedPlaylists = MySongListModel.collectedOfPlaylist(songLists);
    var collectedAlbums = MySongListModel.collectedOfAlbum(songLists);
    return CustomScrollView(
      slivers: <Widget>[
// 暂不支持播放历史和本地音乐
//        SliverToBoxAdapter(
//          child: Container(
//            color: Colors.white,
//            child: Column(
//              children: <Widget>[
//                //播放历史
//                _HomeMyCommonItem('history', stringsOf(context).recentlyPlayed, 28),
//                _HomeMyCommonDivider(),
//                _HomeMyCommonItem('queue_music', stringsOf(context).localMusic, 12),
//              ],
//            ),
//          ),
//        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 8,
          ),
        ),
        SliverToBoxAdapter(
          child: _HomeMySongListTitle(
              stringsOf(context).createdPlaylist, true, createdPlaylists.length),
        ),
        if (createdPlaylists.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var songList = createdPlaylists[index];
                return _HomeMySongListItem(
                  songList,
                  key: Key('${songList.type},${songList.id}'),
                );
              },
              childCount: createdPlaylists.length,
            ),
          ),
        if (collectedPlaylists.isNotEmpty)
          SliverToBoxAdapter(
            child: _HomeMySongListTitle(
                stringsOf(context).collectedPlaylist, false, collectedPlaylists.length),
          ),
        if (collectedPlaylists.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var songList = collectedPlaylists[index];
                return _HomeMySongListItem(
                  songList,
                  key: Key('${songList.type},${songList.id}'),
                );
              },
              childCount: collectedPlaylists.length,
            ),
          ),
        if (collectedAlbums.isNotEmpty)
          SliverToBoxAdapter(
            child: _HomeMySongListTitle(
                stringsOf(context).collectedAlbum, false, collectedAlbums.length),
          ),
        if (collectedAlbums.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var songList = collectedAlbums[index];
                return _HomeMySongListItem(
                  songList,
                  key: Key('${songList.type},${songList.id}'),
                );
              },
              childCount: collectedAlbums.length,
            ),
          ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _HomeMyCommonItem extends StatelessWidget {
  final String icon;
  final String title;
  final int count;

  _HomeMyCommonItem(this.icon, this.title, this.count, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50,
        child: FlatButton(
          padding: EdgeInsets.zero,
          onPressed: () => {},
          child: Row(
            children: <Widget>[
              Container(
                width: 80,
                alignment: Alignment.center,
                child: MdrIcon(
                  icon,
                  size: 28,
                  color: AppColors.tint_rounded,
                ),
              ),
              Text.rich(TextSpan(children: [
                TextSpan(
                    text: title,
                    style: TextStyle(
                      color: AppColors.text_title,
                      fontSize: 16,
                    )),
                TextSpan(
                    text: ' ($count)',
                    style: TextStyle(
                      color: AppColors.text_light,
                      fontSize: 14,
                    ))
              ]))
            ],
          ),
        ));
  }
}

class _HomeMyCommonDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 80),
      height: 1,
      color: AppColors.divider,
    );
  }
}

class _HomeMySongListTitle extends StatelessWidget {
  final String title;
  final bool isCreated;
  final int count;

  _HomeMySongListTitle(this.title, this.isCreated, this.count, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
          MdrIcon(
            'expand_more',
            size: 32,
            color: AppColors.tint_rounded,
          ),
          Expanded(
              flex: 1,
              child: Text.rich(TextSpan(children: [
                TextSpan(
                  text: title,
                  style: TextStyle(
                    color: AppColors.text_dark,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: ' ($count)',
                  style: TextStyle(
                    color: AppColors.text_light,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ]))),
          Visibility(
            visible: isCreated,
            child: Container(
              width: 42,
              alignment: Alignment.center,
              child: FlatButton(
                onPressed: () => showCreatePlaylistDialog(context),
                shape: CircleBorder(),
                padding: EdgeInsets.zero,
                child: MdrIcon(
                  'add',
                  size: 24,
                  color: AppColors.tint_rounded,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _HomeMySongListItem extends StatelessWidget {
  final SongList songList;

  _HomeMySongListItem(this.songList, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
        onPressed: () {
          AppNavigator.instance.navigateTo(context, AppNavigator.song_list, params: {
            'plt': songList.plt,
            'songListId': songList.id,
            'songListType': songList.type,
          });
        },
        padding: EdgeInsets.zero,
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 5, 0, 5),
          height: 60,
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                child: songList?.cover == null || songList.cover.isEmpty
                    ? Container(
                        width: 50,
                        height: 50,
                        color: AppColors.cover_bg,
                      )
                    : CachedNetworkImage(
                        imageUrl: songList.cover,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        placeholder: (context, url) {
                          return Container(
                            width: 50,
                            height: 50,
                            color: AppColors.cover_bg,
                          );
                        },
                      ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      songList.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: AppColors.text_title, fontSize: 16, fontWeight: FontWeight.normal),
                    ),
                    Text(
                      stringsOf(context)
                          .songListCountAndCreator(this.songList.songTotal, this.songList.userName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.text_light,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
              ButtonTheme(
                minWidth: 36,
                child: FlatButton(
                  onPressed: () => showSongListMenu(context, songList),
                  padding: EdgeInsets.zero,
                  child: Icon(
                    Icons.more_vert,
                    color: AppColors.tint_rounded,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
