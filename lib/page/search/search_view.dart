import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:flutter/material.dart';
import 'package:second_music/page/navigator.dart';
import 'package:second_music/page/search/search_logic.dart';
import 'package:second_music/page/search/widget/history.dart';
import 'package:second_music/page/search/widget/result.dart';
import 'package:second_music/res/res.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var searchLogic = SearchLogic();

  @override
  Widget build(BuildContext context) {
    return SearchLogicProvider(
      searchLogic,
      Scaffold(
        appBar: PreferredSize(
            child: SafeArea(
                top: true,
                left: false,
                right: false,
                bottom: false,
                child: SearchBar()),
            preferredSize: Size.fromHeight(50)),
        body: StreamBuilder(
          stream: searchLogic.keywordStream,
          builder: (context, AsyncSnapshot<String> snapshot) {
            if (snapshot.data.isNullOrEmpty()) {
              return SearchHistoryWidget();
            } else {
              return SearchResultWidget(snapshot.data!);
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    searchLogic.dispose();
  }
}

class SearchLogicProvider extends InheritedWidget {
  final SearchLogic logic;

  SearchLogicProvider(this.logic, Widget child, {Key? key})
      : super(child: child, key: key);

  @override
  bool updateShouldNotify(SearchLogicProvider oldWidget) =>
      logic != oldWidget.logic;

  static SearchLogicProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SearchLogicProvider>()!;
}

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var searchLogic = SearchLogicProvider.of(context).logic;
    return Container(
      padding: EdgeInsets.only(left: 15),
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Ink(
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.searchBg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      Icons.search_rounded,
                      color: AppColors.textLight,
                      size: 24,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: searchLogic.searchEditingController,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onSubmitted: searchLogic.submit,
                      decoration: InputDecoration(
                        hintText: stringsOf(context).searchHint,
                        hintStyle: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true, //是文本垂直居中
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: InkWell(
                      onTap: () {
                        searchLogic.setInputText('');
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: AppColors.tintRounded,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () => AppNavigator().pop(context),
            child: Text(
              stringsOf(context).cancel,
              style: TextStyle(
                color: AppColors.textTitle,
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
