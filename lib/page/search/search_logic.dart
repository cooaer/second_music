import 'dart:async';

import 'package:flutter/material.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/search.dart';
import 'package:second_music/repository/local/preference/playing.dart';
import 'package:second_music/repository/remote/platform/music_provider.dart';

class SearchLogic {
  late List<String> _searchKeywords;

  SearchLogic() {
    _searchKeywords = PlayingStorage.instance.searchKeywords;
  }

  var _searchEditingController = TextEditingController();

  TextEditingController get searchEditingController => _searchEditingController;

  var _keywordController = StreamController<String>.broadcast();

  Stream<String> get keywordStream => _keywordController.stream;

  var _keywordHistoryController = StreamController<List<String>>.broadcast();

  Stream<List<String>> get keywordHistoryStream =>
      _keywordHistoryController.stream;

  void submit(String text) {
    _keywordController.add(text);
    if (text.isNotEmpty) {
      _saveKeyword(text);
    }
  }

  void _saveKeyword(String keyword) {
    _searchKeywords.remove(keyword);
    _searchKeywords.insert(0, keyword);
    if (_searchKeywords.length > 20) {
      //本地最多保存20条搜索记录
      _searchKeywords.removeLast();
    }
    _keywordHistoryController.add(_searchKeywords);
    PlayingStorage.instance.saveSearchKeywords(_searchKeywords);
  }

  void setInputText(String text) {
    _searchEditingController.value = TextEditingValue(
        text: text,
        selection:
            TextSelection.fromPosition(TextPosition(offset: text.length)));
    submit(text);
  }

  void clearKeywords() {
    _searchKeywords.clear();
    _keywordHistoryController.add(_searchKeywords);
    PlayingStorage.instance.saveSearchKeywords(_searchKeywords);
  }

  dispose() {
    _searchEditingController.dispose();
    _keywordController.close();
  }
}

class SearchObjectLogic {
  static const SEARCH_PLTS = [
    MusicPlatform.netease,
    MusicPlatform.qq,
    MusicPlatform.migu
  ];

  static const REQUEST_COUNT = 5;
  static const DISTANCE_TO_BOTTOM_REQUEST_MORE = 50;

  final MusicObjectType type;
  String _keyword;
  final List<MusicPlatform> _plts;
  final int requestCount;

  final scrollController = ScrollController();

  SearchObjectLogic(this.type, this._keyword,
      {List<MusicPlatform> plts = SEARCH_PLTS,
      this.requestCount = REQUEST_COUNT})
      : this._plts = plts {
    _listenScrollToBottom();
  }

  void _listenScrollToBottom() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >
          scrollController.position.maxScrollExtent -
              DISTANCE_TO_BOTTOM_REQUEST_MORE) {
        requestMore(false);
      }
    });
  }

  var _loading = false;

  bool get loading => _loading;

  // 有一个渠道请求成功就算是没有失败
  bool get lastError {
    if (_results.isEmpty) return false;
    for (SearchResult result in _results.values) {
      if (!result.hasError) return false;
    }
    return true;
  }

  var _results = <MusicPlatform, SearchResult>{};

  Map<MusicPlatform, SearchResult> get results => _results;
  var _resultController =
      StreamController<Map<MusicPlatform, SearchResult>>.broadcast();

  Stream<Map<MusicPlatform, SearchResult>> get resultStream =>
      _resultController.stream;

  bool hasMore() {
    if (_results.isEmpty) return true;
    return _plts.any((plt) => _results[plt]?.hasMore == true);
  }

  set keyword(String text) {
    if (_keyword == text) return;
    _keyword = text;

    _results.clear();
    _resultController.add(_results);

    if (_keyword.isEmpty) return;

    refresh();
  }

  String get keyword => _keyword;

  void refresh() {
    debugPrint("SearchObjLogic.request, start");
    _refreshInternal();
  }

  void _refreshInternal() async {
    _loading = true;

    var loadingPlts = _plts.length;

    void onSearchPlatformFinished(MusicPlatform plt) {
      loadingPlts--;
      _loading = loadingPlts > 0;
      if (!_loading) {
        debugPrint("SearchObjLogic.requestInternal, end");
      }

      //网易云音乐每次搜索只返回10条，无法触发滚动自动加载更多，所以需要在请求一次
      if (_plts.length == 1) {
        final result = results[plt];
        if (result == null) {
          return;
        }
        if (!result.hasError && result.hasMore && result.items.length < 20) {
          _refreshInternal();
        }
      }
    }

    void searchPlatform(MusicPlatform plt) async {
      SearchResult? _lastResult;
      if (_results.containsKey(plt)) {
        _lastResult = _results[plt];
        // 该平台已经搜索完毕
        if (_lastResult == null || !_lastResult.hasMore) {
          onSearchPlatformFinished(plt);
          return;
        }
      } else {
        _lastResult = SearchResult();
      }

      final result = await MusicProvider(plt).search(_keyword, type,
          page: _lastResult.nextPage, count: requestCount);
      debugPrint(
          "SearchObjLogic.searchPlatform, start plt = $plt, type = $type, keyword = $_keyword, page = ${_lastResult.nextPage}");

      if (result != null && result.items.isNotEmpty) {
        _lastResult.page++;
        _lastResult.hasError = false;
        _lastResult.total = result.total;
        _lastResult.items.addAll(result.items);
      } else {
        _lastResult.hasError = true;
      }

      _results[plt] = _lastResult;
      if (!_resultController.isClosed) {
        _resultController.add(_results);
      }
      onSearchPlatformFinished(plt);
    }

    for (MusicPlatform plt in _plts) {
      searchPlatform(plt);
    }
  }

  void requestMore(bool force) {
    if (!force && lastError) return;
    if (!hasMore()) return;
    if (loading) return;
    debugPrint("SearchObjLogic.requestMore, start, force = $force");
    _refreshInternal();
  }

  void dispose() {
    _resultController.close();
  }
}
