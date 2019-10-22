import 'package:PureBook/entity/Chapter.dart';
import 'package:PureBook/event/event.dart';
import 'package:PureBook/model/ThemeModel.dart';
import 'package:PureBook/store/Store.dart';
import 'package:flutter/material.dart';

class ChapterView extends StatefulWidget {
  List<Chapter> chapters = [];
  String bookId;
  int cur;
  String bookName;

  ChapterView(this.chapters, this.bookId, this.cur, this.bookName);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ChapterViewItem(bookId, cur, chapters, bookName);
  }
}

class _ChapterViewItem extends State<ChapterView> {
  List<Chapter> chapters = [];
  String bookId;
  int cur;
  String bookName;
  ScrollController _scrollController = new ScrollController();

  double ITEM_HEIGH = 50.0;
  int ii = 0;
  bool up = false;
  int curIndex = 0;
  bool showToTopBtn = false; //是否显示“返回到顶部”按钮
  _ChapterViewItem(this.bookId, this.cur, this.chapters, this.bookName);

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    var widgetsBinding = WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((callback) {
      scrollTo();
    });
    //监听滚动事件，打印滚动位置
    _scrollController.addListener(() {
      if (_scrollController.offset < ITEM_HEIGH * 8 && showToTopBtn) {
        setState(() {
          showToTopBtn = false;
        });
      } else if (_scrollController.offset >= 1000 && showToTopBtn == false) {
        setState(() {
          showToTopBtn = true;
        });
      }
    });
  }

//滚动到当前阅读位置
  scrollTo() async {
    if (_scrollController.hasClients) {
      curIndex = cur - 8;
      await _scrollController.animateTo((cur - 8) * ITEM_HEIGH,
          duration: new Duration(microseconds: 1), curve: Curves.ease);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    Widget listView = new ListView.builder(
      controller: _scrollController,
      itemExtent: ITEM_HEIGH,
      itemBuilder: (context, index) {
        var title = chapters[index].name;
        var has = chapters[index].hasContent;
        padding:
        EdgeInsets.all(16.0);
        return ListTile(
          title: getTitle(title, has),
          trailing: new Text(
            has == 2 ? "已缓存" : "",
            style: TextStyle(fontSize: 8, color: Colors.grey),
          ),
          selected: index == cur,
          onTap: () {
            if (has > 0) {
              //不是卷目录
              Navigator.of(context).pop();
              eventBus.fire(new ChapterEvent(index));
            }
          },
        );
      },
      itemCount: chapters.length,
    );

    return Scaffold(
      appBar: AppBar(
        title: new Text(
          bookName,
          style: TextStyle(
              color: Store.value<AppThemeModel>(context)
                  .getThemeData()
                  .iconTheme
                  .color,
              fontSize: 16.0),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Scrollbar(
        child: listView,
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: topOrBottom,
          child: Icon(
            showToTopBtn ? Icons.arrow_upward : Icons.arrow_downward,
          )),
    );
  }

  topOrBottom() async {
    if (_scrollController.hasClients) {
      int temp = showToTopBtn ? 1 : chapters.length - 8;
      await _scrollController.animateTo(temp * ITEM_HEIGH,
          duration: new Duration(microseconds: 1), curve: Curves.ease);
    }
  }

  getTitle(title, has) {
    Widget widget;
    if (has == 0) {
      widget = new Text(
        title,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
      );
    } else {
      widget = new Text(
        title,
        style: TextStyle(fontSize: 12),
      );
    }
    return widget;
  }
}
