//搜索结果
class SearchResult {
  int page = -1;
  bool hasError = false;

  int total = 0;
  List items = [];

  bool get hasMore => total > items.length;

  int get nextPage => page + 1;
}
