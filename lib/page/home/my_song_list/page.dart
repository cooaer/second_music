import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:second_music/entity/song_list.dart';
import 'package:second_music/page/home/my_song_list/logic.dart';
import 'package:second_music/page/home/my_song_list/widget.dart';
import 'package:second_music/page/navigator.dart';
import 'package:second_music/res/res.dart';

class HomeMySongList extends StatefulWidget {
  @override
  State createState() {
    return HomeMySongListState();
  }
}

class HomeMySongListState extends State with AutomaticKeepAliveClientMixin {
  late MySongListLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = MySongListLogic.instance;
    _logic.refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder(
      stream: MySongListLogic.instance.mySongListStream,
      builder: (context, AsyncSnapshot<List<SongList>> snapshot) {
        return _buildContent(context, snapshot.data ?? []);
      },
    );
  }

  Widget _buildContent(BuildContext context, List<SongList> songLists) {
    var createdPlaylists = MySongListLogic.createdOfPlaylist(songLists);
    var collectedPlaylists = MySongListLogic.collectedOfPlaylist(songLists);
    var collectedAlbums = MySongListLogic.collectedOfAlbum(songLists);
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
          child: _HomeMySongListTitle(stringsOf(context).createdPlaylist, true,
              createdPlaylists.length),
        ),
        if (createdPlaylists.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var songList = createdPlaylists[index];
                return _HomeMySongListItem(
                  songList,
                  key: Key('${songList.type},${songList.pltId}'),
                );
              },
              childCount: createdPlaylists.length,
            ),
          ),
        if (collectedPlaylists.isNotEmpty)
          SliverToBoxAdapter(
            child: _HomeMySongListTitle(stringsOf(context).collectedPlaylist,
                false, collectedPlaylists.length),
          ),
        if (collectedPlaylists.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var songList = collectedPlaylists[index];
                return _HomeMySongListItem(
                  songList,
                  key: Key('${songList.type},${songList.pltId}'),
                );
              },
              childCount: collectedPlaylists.length,
            ),
          ),
        if (collectedAlbums.isNotEmpty)
          SliverToBoxAdapter(
            child: _HomeMySongListTitle(stringsOf(context).collectedAlbum,
                false, collectedAlbums.length),
          ),
        if (collectedAlbums.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var songList = collectedAlbums[index];
                return _HomeMySongListItem(
                  songList,
                  key: Key('${songList.type},${songList.pltId}'),
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
  final IconData icon;
  final String title;
  final int count;

  _HomeMyCommonItem(this.icon, this.title, this.count, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50,
        child: InkWell(
          onTap: () => {},
          child: Row(
            children: <Widget>[
              Container(
                width: 80,
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 28,
                  color: AppColors.tintRounded,
                ),
              ),
              Text.rich(TextSpan(children: [
                TextSpan(
                    text: title,
                    style: TextStyle(
                      color: AppColors.textTitle,
                      fontSize: 16,
                    )),
                TextSpan(
                    text: ' ($count)',
                    style: TextStyle(
                      color: AppColors.textLight,
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

  _HomeMySongListTitle(this.title, this.isCreated, this.count, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.expand_more_rounded,
            size: 32,
            color: AppColors.tintRounded,
          ),
          Expanded(
              flex: 1,
              child: Text.rich(TextSpan(children: [
                TextSpan(
                  text: title,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: ' ($count)',
                  style: TextStyle(
                    color: AppColors.textLight,
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
              child: IconButton(
                onPressed: () => showCreatePlaylistDialog(context),
                padding: EdgeInsets.zero,
                icon: Icon(Icons.add),
                color: AppColors.tintRounded,
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

  _HomeMySongListItem(this.songList, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AppNavigator().navigateTo(context, AppNavigator.song_list, params: {
          'plt': songList.plt,
          'songListId': songList.pltId,
          'songListType': songList.type,
        });
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 5, 0, 5),
        height: 60,
        child: Row(
          children: <Widget>[
            songList.buildCoverWidget(context),
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
                        color: AppColors.textTitle,
                        fontSize: 16,
                        fontWeight: FontWeight.normal),
                  ),
                  Text(
                    stringsOf(context).songListCountAndCreator(
                        this.songList.songTotal, this.songList.userName),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            ),
            IconButton(
              onPressed: () => showSongListMenu(context, songList),
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.more_vert,
                color: AppColors.tintRounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension SongListWidgetBuilder on SongList {
  Widget buildCoverWidget(BuildContext context) {
    Widget coverView;
    if (this.isFavor) {
      coverView = Container(
        width: 50,
        height: 50,
        color: AppColors.coverBg,
        child: Icon(
          Icons.favorite_rounded,
          size: 32,
          color: AppColors.accent,
        ),
      );
    } else if (this.cover.isNotEmpty) {
      coverView = CachedNetworkImage(
        imageUrl: this.cover,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        placeholder: (context, url) {
          return Container(
            width: 50,
            height: 50,
            color: AppColors.coverBg,
          );
        },
      );
    } else {
      coverView = Container(
        width: 50,
        height: 50,
        color: AppColors.coverBg,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(5)),
      child: coverView,
    );
  }
}
