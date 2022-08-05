import 'package:flutter/material.dart';
import 'package:second_music/page/search/page.dart';
import 'package:second_music/repository/local/preference/playing.dart';
import 'package:second_music/res/res.dart';
import 'package:second_music/widget/material_icon_round.dart';

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
                      color: AppColors.text_title,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
              ButtonTheme(
                minWidth: 0,
                child: FlatButton(
                    onPressed: searchModel.clearKeywords,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    shape: CircleBorder(),
                    child: MdrIcon(
                      'delete_outline',
                      color: AppColors.text_light,
                      size: 24,
                    )),
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
    return ButtonTheme(
        minWidth: 0,
        height: 32,
        child: FlatButton(
          onPressed: () {
            //隐藏键盘
            FocusScope.of(context).requestFocus(FocusNode());
            SearchModelProvider.of(context).model.setInputText(key);
          },
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          color: AppColors.page_background,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          child: Column(
            children: <Widget>[
              Text(
                key,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.text_title,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ));
  }
}
