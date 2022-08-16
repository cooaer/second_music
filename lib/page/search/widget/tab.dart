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
import 'package:second_music/page/mini_player/mini_player_page.dart';
import 'package:second_music/page/navigator.dart';
import 'package:second_music/page/search/model.dart';
import 'package:second_music/page/song_list/widget.dart';
import 'package:second_music/repository/local/preference/config.dart';
import 'package:second_music/res/res.dart';
import 'package:second_music/widget/loading_more.dart';
import 'package:second_music/widget/material_icon_round.dart';

class SearchObjectTab extends StatefulWidget {
  final String keyword;
  final MusicObjectType type;

  SearchObjectTab(this.keyword, this.type, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchObjectTabState();
}

class _SearchObjectTabState extends State<SearchObjectTab>
    with AutomaticKeepAliveClientMixin {
  late SearchObjectModel _model;

  @override
  void initState() {
    super.initState();
    _model = SearchObjectModel(widget.type, widget.keyword);
    _model.selected = true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var plts = AppConfig.instance.searchPltRank;
    return StreamBuilder(
      stream: _model.resultStream,
      builder:
          (context, AsyncSnapshot<Map<MusicPlatform, SearchResult>> snapshot) {
        return CustomScrollView(
          slivers: <Widget>[
            if (snapshot.data != null)
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  var plt = plts[index];
                  var result = snapshot.data![plt]!;
                  return result.items.isNotEmpty
                      ? _SearchResultItemWidget(
                          plt, widget.keyword, widget.type, result,
                          key: ValueKey(plt))
                      : Container();
                }, childCount: plts.length),
              ),
            if (_model.hasMore() &&
                (snapshot.data == null || snapshot.data!.length < plts.length))
              SliverToBoxAdapter(
                child: LoadingMore(_model.loading, _model.lastError, () {}),
              ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).padding.bottom +
                    MiniPlayer.ALL_HEIGHT,
              ),
            )
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _model.dispose();
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
        _SearchResultTitle(plt, keyword, type,
            searchResult.hasMore || searchResult.items.length > PLT_MAX_COUNT),
      ]..addAll(_buildItemsWidget(context, searchResult.items)),
    );
  }

  List<Widget> _buildItemsWidget(BuildContext context, List items) {
    var maxCount = min(PLT_MAX_COUNT, items.length);
    return List.generate(maxCount, (index) {
      var item = items[index];
      if (item is Song) {
        return _SearchResultSong(item);
      }
      if (item is Playlist) {
        return _SearchResultSongList(SongList.fromPlaylist(item));
      }
      if (item is Album) {
        return _SearchResultSongList(SongList.fromAlbum(item));
      }
      if (item is Singer) {
        return _SearchResultSinger(item);
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
              color: AppColors.text_light,
              fontWeight: FontWeight.w500,
            ),
          ),
          Spacer(),
          if (hasMore)
            ButtonTheme(
              minWidth: 0,
              child: FlatButton(
                onPressed: () {},
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      stringsOf(context).more,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.text_light,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(
                      width: 20,
                      child: MdrIcon(
                        'navigate_next',
                        size: 20,
                        color: AppColors.tint_rounded,
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

class _SearchResultSong extends StatelessWidget {
  final Song _song;

  _SearchResultSong(this._song) : super(key: ValueKey(_song));

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      height: 60,
      minWidth: 0,
      child: FlatButton(
        onPressed: () {
          AppNavigator.instance.navigateTo(context, AppNavigator.play,
              params: {'song': _song}, overlay: true);
        },
        padding: EdgeInsets.zero,
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
                      color: AppColors.cover_bg,
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
                          color: AppColors.cover_bg,
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
                children: <Widget>[
                  Text(
                    _song.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.text_title,
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
                      color: AppColors.text_light,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            FlatButton(
              onPressed: () => showSongMenu(context, _song, null, null),
              shape: CircleBorder(),
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: MdrIcon(
                'more_vert',
                size: 24,
                color: AppColors.tint_rounded,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _SearchResultSongList extends StatelessWidget {
  final SongList _songList;

  _SearchResultSongList(this._songList, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
        onPressed: () {
          AppNavigator.instance
              .navigateTo(context, AppNavigator.song_list, params: {
            'plt': _songList.plt,
            'songListId': _songList.pltId,
            'songListType': _songList.type,
          });
        },
        padding: EdgeInsets.zero,
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
                        color: AppColors.cover_bg,
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
                      _songList.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: AppColors.text_title,
                          fontSize: 16,
                          fontWeight: FontWeight.normal),
                    ),
                    Text(
                      stringsOf(context).songListCountAndCreator(
                          this._songList.songTotal, this._songList.userName),
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
            ],
          ),
        ));
  }
}

class _SearchResultSinger extends StatelessWidget {
  final Singer _singer;

  _SearchResultSinger(this._singer, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {},
      padding: EdgeInsets.zero,
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
                      color: AppColors.cover_bg,
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
                child: Text(_singer.name,
                    style:
                        TextStyle(fontSize: 16, color: AppColors.text_title)))
          ],
        ),
      ),
    );
  }
}
