import 'package:flutter/material.dart';
import 'package:second_music/page/navigator.dart';
import 'package:second_music/page/search/model.dart';
import 'package:second_music/page/search/widget/history.dart';
import 'package:second_music/page/search/widget/result.dart';
import 'package:second_music/res/res.dart';
import 'package:second_music/widget/material_icon_round.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var searchModel = SearchModel();

  @override
  Widget build(BuildContext context) {
    return SearchModelProvider(
      searchModel,
      Scaffold(
        appBar: PreferredSize(
            child:
                SafeArea(top: true, left: false, right: false, bottom: false, child: SearchBar()),
            preferredSize: Size.fromHeight(50)),
        body: StreamBuilder(
          stream: searchModel.keywordStream,
          builder: (context, AsyncSnapshot<String> snapshot) {
            if (snapshot?.data == null || snapshot.data.isEmpty) {
              return SearchHistoryWidget();
            } else {
              return SearchResultWidget(snapshot.data);
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    searchModel.dispose();
  }
}

class SearchModelProvider extends InheritedWidget {
  final SearchModel model;

  SearchModelProvider(this.model, Widget child, {Key key}) : super(child: child, key: key);

  @override
  bool updateShouldNotify(SearchModelProvider oldWidget) => model != oldWidget.model;

  static SearchModelProvider of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(SearchModelProvider);
}

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var searchModel = SearchModelProvider.of(context).model;
    return Container(
      padding: EdgeInsets.only(left: 15),
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.search_bg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: MdrIcon(
                      'search',
                      color: AppColors.text_light,
                      size: 24,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: searchModel.searchEditingController,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onSubmitted: searchModel.submit,
                      decoration: InputDecoration(
                        hintText: stringsOf(context).searchHint,
                        hintStyle: TextStyle(
                          color: AppColors.text_light,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  ButtonTheme(
                    minWidth: 0,
                    child: FlatButton(
                      onPressed: (){
                        searchModel.setInputText('');
                      },
                      padding: EdgeInsets.zero,
                      shape: CircleBorder(),
                      child:Container(
                        width: 36,
                        alignment: Alignment.center,
                        child:MdrIcon(
                          'close',
                          size: 20,
                          color: AppColors.tint_rounded,
                        )
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          ButtonTheme(
            minWidth: 0,
            child: FlatButton(
              onPressed: AppNavigator.instance.of(context).pop,
              padding: EdgeInsets.symmetric(horizontal: 15),
              shape: CircleBorder(),
              child: Text(
                stringsOf(context).cancel,
                style: TextStyle(
                  color: AppColors.text_title,
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchMorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return null;
  }
}
