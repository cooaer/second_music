import 'dart:async';

import 'package:flutter/material.dart';
import 'package:second_music/model/enum.dart';
import 'package:second_music/model/search.dart';
import 'package:second_music/network/platform/music_provider.dart';
import 'package:second_music/storage/preference/playing.dart';

class SearchModel {
  List<String> _searchKeywords;

  SearchModel() {
    _searchKeywords = PlayingStorage.instance.searchKeywords();
  }

  var _searchEditingController = TextEditingController();

  TextEditingController get searchEditingController => _searchEditingController;

  var _keywordController = StreamController<String>.broadcast();

  Stream<String> get keywordStream => _keywordController.stream;

  var _keywordHistoryController = StreamController<List<String>>.broadcast();

  Stream<List<String>> get keywordHistoryStream => _keywordHistoryController.stream;

  void submit(String text) {
    _keywordController.add(text);
    if (text != null && text.isNotEmpty) {
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
        text: text, selection: TextSelection.fromPosition(TextPosition(offset: text.length)));
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
  bool _selected;
  List<String> _plts;

  SearchObjectModel(this.type, this._keyword, {List<String> plts = MusicPlatforms.platforms})
      : this._plts = plts;

  static const REQUEST_COUNT = 20;

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

  var _results = <String, SearchResult>{};

  Map<String, SearchResult> get results => _results;
  var _resultController = StreamController<Map<String, SearchResult>>.broadcast();

  Stream<Map<String, SearchResult>> get resultStream => _resultController.stream;

  bool hasMore({List<String> plts}) {
    if (_results.isEmpty) return true;
    plts = plts ?? _plts;
    for (String plt in plts) {
      if (_results.containsKey(plt) && _results[plt].hasMore) {
        return true;
      }
    }
    return false;
  }

  set keyword(String text) {
    if (_keyword == text) return;
    _keyword = text;

    _results.clear();
    _resultController.add(_results);

    if (_keyword == null || _keyword.isEmpty) return;

    refresh(false);
  }

  String get keyword => _keyword;

  set selected(bool selected) {
    if (_selected == selected) return;
    _selected = selected;
    refresh(false);
  }

  bool get selected => _selected;

  refresh(bool force, {List<String> plts}) {
    if (!force && !selected) return;
    _refreshInternal(plts: plts);
  }

  _refreshInternal({List<String> plts}) async {
    plts = plts ?? _plts;

    _loading = true;

    for (String plt in plts) {
      SearchResult _lastResult;
      if (_results.containsKey(plt)) {
        _lastResult = _results[plt];
        // 该平台已经搜索完毕
        if (!_lastResult.hasMore) continue;
      } else {
        _lastResult = SearchResult();
        _results[plt] = _lastResult;
      }

      var musicProvider = MusicProvider(plt);
      if (musicProvider == null) continue;

      SearchResult result = await musicProvider.search(_keyword, type,
          page: _lastResult.nextPage, count: REQUEST_COUNT);
      if (result?.items != null && result.items.isNotEmpty) {
        _lastResult.page++;
        _lastResult.hasError = false;
        _lastResult.total = result.total;
        _lastResult.items.addAll(result.items);
      } else {
        _lastResult.hasError = true;
      }
      _resultController.add(_results);
    }

    _loading = false;
  }

  requestMore(bool force, {List<String> plts}) {
    if (!force && lastError) return;
    refresh(force, plts: plts);
  }

  void dispose() {
    _resultController.close();
  }
}
