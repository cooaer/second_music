import 'package:flutter/material.dart';
import 'package:second_music/page/search/page.dart';
import 'package:second_music/repository/local/preference/playing.dart';
import 'package:second_music/res/res.dart';

class SearchHistoryWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var searchModel = SearchModelProvider.of(context).model;
    return Container(
      padding: EdgeInsets.fromLTRB(15, 0, 15, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    stringsOf(context).searchHistory,
                    style: TextStyle(
                      color: AppColors.textTitle,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
              InkWell(
                onTap: searchModel.clearKeywords,
                borderRadius: BorderRadius.circular(22),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.textLight,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          StreamBuilder(
            initialData: PlayingStorage.instance.searchKeywords,
            stream: searchModel.keywordHistoryStream,
            builder: (context, AsyncSnapshot<List<String>> snapshot) {
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.spaceBetween,
                children: buildHistoryItems(context, snapshot.data!),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> buildHistoryItems(BuildContext context, List<String> keys) {
    return keys.map((key) => buildHistoryItem(context, key)).toList();
  }

  Widget buildHistoryItem(BuildContext context, String key) {
    return Ink(
      height: 32,
      decoration: BoxDecoration(
          color: AppColors.pageBackground,
          borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          //隐藏键盘
          FocusScope.of(context).requestFocus(FocusNode());
          SearchModelProvider.of(context).model.setInputText(key);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Text(
            key,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTitle,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
