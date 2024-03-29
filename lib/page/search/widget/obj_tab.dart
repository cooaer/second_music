import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:second_music/entity/album.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/playlist.dart';
import 'package:second_music/entity/search.dart';
import 'package:second_music/entity/singer.dart';
import 'package:second_music/entity/song.dart';
import 'package:second_music/entity/song_list.dart';
import 'package:second_music/page/navigator.dart';
import 'package:second_music/page/search/search_logic.dart';
import 'package:second_music/page/song_list/widget.dart';
import 'package:second_music/res/res.dart';
import 'package:second_music/widget/loading_more.dart';

class SearchObjectTab extends StatefulWidget {
  final String keyword;
  final MusicObjectType type;

  SearchObjectTab(this.keyword, this.type, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchObjectTabState();
}

class _SearchObjectTabState extends State<SearchObjectTab>
    with AutomaticKeepAliveClientMixin {
  late SearchObjectLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = SearchObjectLogic(widget.type, widget.keyword);
    _logic.refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var plts = SearchObjectLogic.SEARCH_PLTS;
    return StreamBuilder(
      stream: _logic.resultStream,
      builder:
          (context, AsyncSnapshot<Map<MusicPlatform, SearchResult>> snapshot) {
        return CustomScrollView(
          slivers: <Widget>[
            if (snapshot.data != null)
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  var plt = plts[index];
                  var result = snapshot.data![plt];
                  return result != null && result.items.isNotEmpty
                      ? _SearchResultItemWidget(
                          plt, widget.keyword, widget.type, result,
                          key: ValueKey(plt))
                      : Container();
                }, childCount: plts.length),
              ),
            if (_logic.hasMore() &&
                (snapshot.data == null || snapshot.data!.length < plts.length))
              SliverToBoxAdapter(
                child: LoadingMore(_logic.loading, _logic.lastError, () {}),
              ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _logic.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

class _SearchResultItemWidget extends StatelessWidget {
  static const PLT_MAX_COUNT = 5;

  final MusicPlatform plt;
  final String keyword;
  final MusicObjectType type;
  final SearchResult searchResult;

  _SearchResultItemWidget(this.plt, this.keyword, this.type, this.searchResult,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _SearchResultTitle(plt, keyword, type, searchResult.hasMore),
      ]..addAll(_buildItemsWidget(context, searchResult.items)),
    );
  }

  List<Widget> _buildItemsWidget(BuildContext context, List items) {
    var maxCount = min(PLT_MAX_COUNT, items.length);
    return List.generate(maxCount, (index) {
      var item = items[index];
      if (item is Song) {
        return SearchResultSong(item);
      }
      if (item is Playlist) {
        return SearchResultSongList(SongList.fromPlaylist(item));
      }
      if (item is Album) {
        return SearchResultSongList(SongList.fromAlbum(item));
      }
      if (item is Singer) {
        return SearchResultSinger(item);
      }
      return null;
    }).whereType<Widget>().toList();
  }
}

class _SearchResultTitle extends StatelessWidget {
  final MusicPlatform plt;
  final String keyword;
  final MusicObjectType type;
  final bool hasMore;

  _SearchResultTitle(this.plt, this.keyword, this.type, this.hasMore,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 24,
          ),
          Container(
            width: 5,
            height: 15,
            decoration: BoxDecoration(
              color: AppColors.platform(plt),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            stringsOf(context).platform(plt),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          Spacer(),
          if (hasMore)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextButton(
                onPressed: () => _onTapMoreButton(context),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      stringsOf(context).more,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Icon(
                      Icons.navigate_next_rounded,
                      size: 20,
                      color: AppColors.tintRounded,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onTapMoreButton(BuildContext context) {
    AppNavigator().navigateTo(context, AppNavigator.search_more, params: {
      'plt': plt,
      'type': type,
      'keyword': keyword,
    });
  }
}

class SearchResultSong extends StatelessWidget {
  final Song _song;

  SearchResultSong(this._song) : super(key: ValueKey(_song));

  @override
  Widget build(BuildContext context) {
    return Ink(
      height: 60,
      child: InkWell(
        onTap: () {
          if (_song.isPlayable) {
            AppNavigator().navigateTo(context, AppNavigator.play,
                params: {'song': _song}, overlay: true);
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 16,
            ),
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              child: _song.cover.isEmpty
                  ? Container(
                      width: 50,
                      height: 50,
                      color: AppColors.coverBg,
                    )
                  : CachedNetworkImage(
                      imageUrl: _song.cover,
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
                    ),
            ),
            SizedBox(
              width: 16,
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    _song.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: _song.isPlayable
                          ? AppColors.textTitle
                          : AppColors.textDisabled,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    stringsOf(context)
                        .singerAndAlbum(_song.singer?.name, _song.album?.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: _song.isPlayable
                          ? AppColors.textTitle
                          : AppColors.textDisabled,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => showSongMenu(context, _song, null, null),
              padding: EdgeInsets.symmetric(horizontal: 10),
              icon: Icon(
                Icons.more_vert_rounded,
                size: 24,
                color: AppColors.tintRounded,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SearchResultSongList extends StatelessWidget {
  final SongList _songList;

  SearchResultSongList(this._songList, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AppNavigator().navigateTo(context, AppNavigator.song_list, params: {
          'plt': _songList.plt,
          'songListId': _songList.pltId,
          'songListType': _songList.type,
        });
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 5, 16, 5),
        height: 60,
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              child: _songList.cover.isEmpty
                  ? Container(
                      width: 50,
                      height: 50,
                      color: AppColors.coverBg,
                    )
                  : CachedNetworkImage(
                      imageUrl: _songList.cover,
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
                    _songList.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppColors.textTitle,
                        fontSize: 16,
                        fontWeight: FontWeight.normal),
                  ),
                  Text(
                    stringsOf(context).songListCountAndCreator(
                        this._songList.songTotal, this._songList.userName),
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
          ],
        ),
      ),
    );
  }
}

class SearchResultSinger extends StatelessWidget {
  final Singer _singer;

  SearchResultSinger(this._singer, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AppNavigator().navigateTo(context, AppNavigator.singer, params: {
          'plt': _singer.plt,
          'singerId': _singer.pltId,
          'singer': _singer,
        });
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 5, 16, 5),
        height: 60,
        child: Row(
          children: <Widget>[
            ClipOval(
              child: _singer.avatar.isEmpty
                  ? Container(
                      width: 50,
                      height: 50,
                      color: AppColors.coverBg,
                    )
                  : CachedNetworkImage(
                      imageUrl: _singer.avatar,
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
                    ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
                flex: 1,
                child: Text(_singer.name,
                    style: TextStyle(fontSize: 16, color: AppColors.textTitle)))
          ],
        ),
      ),
    );
  }
}
