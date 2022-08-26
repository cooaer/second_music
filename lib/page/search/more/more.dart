import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:second_music/entity/album.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/playlist.dart';
import 'package:second_music/entity/search.dart';
import 'package:second_music/entity/singer.dart';
import 'package:second_music/entity/song.dart';
import 'package:second_music/entity/song_list.dart';
import 'package:second_music/page/search/search_logic.dart';
import 'package:second_music/page/search/widget/obj_tab.dart';
import 'package:second_music/widget/loading_more.dart';

class SearchMorePage extends StatefulWidget {
  final MusicPlatform plt;
  final MusicObjectType type;
  final String keyword;

  SearchMorePage(this.plt, this.type, this.keyword);

  @override
  State<StatefulWidget> createState() => _SearchMorePageState();
}

class _SearchMorePageState extends State<SearchMorePage> {
  static const REQUEST_COUNT = 20;
  late SearchObjectLogic logic;

  @override
  void initState() {
    super.initState();
    logic = SearchObjectLogic(widget.type, widget.keyword,
        plts: [widget.plt], requestCount: REQUEST_COUNT);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      logic.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.keyword),
      ),
      body: StreamBuilder<Map<MusicPlatform, SearchResult>>(
          stream: logic.resultStream,
          builder: (context, snapshot) {
            final searchResult = snapshot.data?[widget.plt];
            return _SearchObjectListView(
                logic, searchResult?.items ?? List.empty());
          }),
    );
  }
}

class _SearchObjectListView extends StatelessWidget {
  final SearchObjectLogic logic;
  final List items;

  const _SearchObjectListView(
    this.logic,
    this.items, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLoading = logic.loading;
    var itemCount = items.length;
    if (isLoading) {
      itemCount++;
    }
    return ListView.builder(
      controller: logic.scrollController,
      padding: EdgeInsets.only(top: 12, bottom: 12),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (isLoading && index == itemCount - 1) {
          return LoadingMore(true, logic.lastError, () {});
        }
        final item = items[index];
        return buildObjectItem(context, item);
      },
    );
  }

  Widget buildObjectItem(BuildContext context, dynamic item) {
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
    return Container();
  }
}
