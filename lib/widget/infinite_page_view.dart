import 'package:flutter/cupertino.dart';

typedef WidgetBuilder = Widget Function(BuildContext context, int index, int readIndex);

class InfinitePageView<T> extends StatefulWidget {
  final List<T> items;
  final PageController pageController;
  final WidgetBuilder itemBuilder;

  InfinitePageView(this.items, this.pageController, this.itemBuilder, {Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _InfinitePageViewState<T>();
  }
}

class _InfinitePageViewState<T> extends State<InfinitePageView> {
  PageController pageController;
  List<T> _items;
  List<T> _virtualItems;

  @override
  void initState() {
    super.initState();
    pageController = widget.pageController ?? PageController();
    _items = widget.items;
    if (_items == null || _items.isEmpty) {
      return;
    }
    _virtualItems = [];
    _virtualItems.add(_items.last);
    _virtualItems.addAll(_items);
    _virtualItems.add(_items.first);
  }

  @override
  Widget build(BuildContext context) {
    if (_items == null || _items.isEmpty) {
      return Container();
    }
    return NotificationListener<ScrollEndNotification>(
        onNotification: _onNotification,
        child: PageView.builder(
          itemBuilder: (context, index) {
            int realIndex;
            if (index == 0) {
              realIndex = _items.length - 1;
            } else if (index == _virtualItems.length - 1) {
              realIndex = 0;
            } else {
              realIndex = index - 1;
            }
            return widget.itemBuilder(
              context,
              index,
              realIndex,
            );
          },
          itemCount: _virtualItems.length,
          controller: widget.pageController,
        ));
  }

  bool _onNotification(ScrollEndNotification notification) {
    var index = pageController.page.round();
    if (index == 0) {
      Future.delayed(Duration(milliseconds: 20), () {
        pageController.jumpToPage(_virtualItems.length - 2);
      });
    } else if (index == _virtualItems.length - 1) {
      Future.delayed(Duration(milliseconds: 20), () {
        pageController.jumpToPage(1);
      });
    }
    return true;
  }
}
