import 'dart:async';

import 'package:flutter/material.dart';
import 'package:second_music/entity/enum.dart';
import 'package:second_music/entity/search.dart';
import 'package:second_music/repository/local/preference/playing.dart';
import 'package:second_music/repository/remote/platform/music_provider.dart';

class SearchModel {
  late List<String> _searchKeywords;

  SearchModel() {
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

class SearchObjectModel {
  final MusicObjectType type;
  String _keyword;
  final List<MusicPlatform> _plts;

  SearchObjectModel(this.type, this._keyword,
      {List<MusicPlatform> plts = MusicPlatform.values})
      : this._plts = plts;

  static const REQUEST_COUNT = 5;

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

    refresh(false);
  }

  String get keyword => _keyword;

  bool _selected = false;

  set selected(bool selected) {
    if (_selected == selected) return;
    _selected = selected;
    refresh(false);
  }

  bool get selected => _selected;

  void refresh(bool force, {List<MusicPlatform> plts = MusicPlatform.values}) {
    if (!force && !selected) return;
    _refreshInternal(plts);
  }

  void _refreshInternal(List<MusicPlatform> plts) async {
    _loading = true;

    for (MusicPlatform plt in plts) {
      SearchResult? _lastResult;
      if (_results.containsKey(plt)) {
        _lastResult = _results[plt];
        // 该平台已经搜索完毕
        if (_lastResult == null || !_lastResult.hasMore) continue;
      } else {
        _lastResult = SearchResult();
        _results[plt] = _lastResult;
      }

      final musicProvider = MusicProvider(plt);

      SearchResult result = await musicProvider.search(_keyword, type,
          page: _lastResult.nextPage, count: REQUEST_COUNT);
      if (result.items.isNotEmpty) {
        _lastResult.page++;
        _lastResult.hasError = false;
        _lastResult.total = result.total;
        _lastResult.items.addAll(result.items);
      } else {
        _lastResult.hasError = true;
      }
      if (!_resultController.isClosed) {
        _resultController.add(_results);
      }
    }

    _loading = false;
  }

  void requestMore(bool force, List<MusicPlatform> plts) {
    if (!force && lastError) return;
    refresh(force, plts: plts);
  }

  void dispose() {
    _resultController.close();
  }
}
