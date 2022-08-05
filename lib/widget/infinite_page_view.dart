import 'package:flutter/cupertino.dart';

typedef WidgetBuilder = Widget Function(
    BuildContext context, int index, int readIndex);

class InfinitePageView<T> extends StatefulWidget {
  final int itemCount;
  final InfinitePageController controller;
  final WidgetBuilder itemBuilder;

  InfinitePageView(this.itemCount, this.controller, this.itemBuilder,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    controller.realSize = itemCount;
    return _InfinitePageViewState<T>();
  }
}

class _InfinitePageViewState<T> extends State<InfinitePageView<T>> {
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.itemCount;
    final virtualItemCount = itemCount + 2;
    if (itemCount == 0) {
      return Container();
    }
    return NotificationListener<ScrollEndNotification>(
        onNotification: _onNotification,
        child: PageView.builder(
          itemBuilder: (context, index) {
            int realIndex;
            if (index == 0) {
              realIndex = itemCount - 1;
            } else if (index == virtualItemCount - 1) {
              realIndex = 0;
            } else {
              realIndex = index - 1;
            }
            print(
                "InfinitePageView.itemBuilder, index = $index, realIndex=$realIndex, count = $itemCount");
            return widget.itemBuilder(
              context,
              index,
              realIndex,
            );
          },
          itemCount: virtualItemCount,
          controller: widget.controller,
        ));
  }

  bool _onNotification(ScrollEndNotification notification) {
    final virtualItemCount = widget.itemCount + 2;
    final page = pageController.page;
    if (page == null) {
      return false;
    }
    var index = page.round();
    if (index == 0) {
      Future.delayed(Duration(milliseconds: 20), () {
        pageController.jumpToPage(virtualItemCount - 2);
      });
    } else if (index == virtualItemCount - 1) {
      Future.delayed(Duration(milliseconds: 20), () {
        pageController.jumpToPage(1);
      });
    }
    return true;
  }
}

class InfinitePageController extends PageController {
  InfinitePageController({
    int initialPage = 1,
    bool keepPage = true,
    double viewportFraction = 1.0,
  }) : super(
            initialPage: initialPage,
            keepPage: keepPage,
            viewportFraction: viewportFraction);

  int realSize = 0;

  @override
  void jumpToPage(int page) {
    final virtualPage = (page + 1) % (realSize + 2);
    super.jumpToPage(virtualPage);
  }

  ///page: 实际列表中的item的index
  @override
  Future<void> animateToPage(int page,
      {required Duration duration, required Curve curve}) {
    final virtualPage = (page + 1) % (realSize + 2);
    return super.animateToPage(virtualPage, duration: duration, curve: curve);
  }

  ///获得页面真实的index
  @override
  double? get page {
    final currentPage = super.page;
    if (currentPage == null) return null;
    return (currentPage - 1) % realSize;
  }
}
