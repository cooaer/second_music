import 'package:flutter/material.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/page/search/widget/tab.dart';
import 'package:second_music/res/res.dart';

class SearchResultWidget extends StatefulWidget {
  final String keyword;

  SearchResultWidget(this.keyword, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchResultWidgetState();
}

class _SearchResultWidgetState extends State<SearchResultWidget>
    with SingleTickerProviderStateMixin {
  static const TAB_LENGTH = 4;
  static const SEARCH_OBJECT_TYPES = [
    MusicObjectType.song,
    MusicObjectType.playlist,
    MusicObjectType.singer,
    MusicObjectType.album
  ];

  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: TAB_LENGTH, vsync: this);
    _tabController.addListener(_handleTabControllerChanges);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        TabBar(
          controller: _tabController,
          tabs: stringsOf(context)
              .searchTabTitles
              .map((title) => Tab(text: title))
              .toList(),
          labelColor: AppColors.text_title,
          labelPadding: EdgeInsets.zero,
          labelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelColor: AppColors.text_light,
          unselectedLabelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
        ),
        Divider(
          height: 1,
          color: AppColors.divider,
        ),
        Expanded(
          flex: 1,
          child: TabBarView(
              controller: _tabController,
              children: List.generate(TAB_LENGTH, (index) {
                return SearchObjectTab(widget.keyword,
                    SEARCH_OBJECT_TYPES[index], _selectedIndex == index,
                    key: ValueKey(SEARCH_OBJECT_TYPES[index]));
              }).toList()),
        )
      ],
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.removeListener(_handleTabControllerChanges);
    _tabController.dispose();
  }

  void _handleTabControllerChanges() {
    var index = _tabController.index.round();
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }
}
