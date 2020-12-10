//搜索结果
class SearchResult {
  int page = 0;
  bool hasError = false;

  int total = 0;
  List items = [];

  bool get hasMore => total > items.length;

  int get nextPage => hasError ? page : page + 1;
}
