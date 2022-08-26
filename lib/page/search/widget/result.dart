import 'package:flutter/material.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/page/search/widget/obj_tab.dart';
import 'package:second_music/res/res.dart';

class SearchResultWidget extends StatelessWidget {
  static const TAB_LENGTH = 4;
  static const SEARCH_OBJECT_TYPES = [
    MusicObjectType.song,
    MusicObjectType.playlist,
    MusicObjectType.singer,
    MusicObjectType.album
  ];

  final String keyword;

  SearchResultWidget(this.keyword, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: DefaultTabController(
        length: TAB_LENGTH,
        child: Column(
          children: <Widget>[
            TabBar(
              tabs: stringsOf(context)
                  .searchTabTitles
                  .map((title) => Tab(text: title))
                  .toList(),
              labelColor: AppColors.textTitle,
              labelPadding: EdgeInsets.zero,
              labelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelColor: AppColors.textLight,
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
                  children: List.generate(TAB_LENGTH, (index) {
                return SearchObjectTab(keyword, SEARCH_OBJECT_TYPES[index],
                    key: Key("${SEARCH_OBJECT_TYPES[index]}"));
              }).toList()),
            )
          ],
        ),
      ),
    );
  }
}
