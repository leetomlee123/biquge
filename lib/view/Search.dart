import 'dart:convert';

import 'package:PureBook/common/util.dart';
import 'package:PureBook/entity/BookInfo.dart';
import 'package:PureBook/entity/SearchItem.dart';
import 'package:PureBook/view/MySearchDelegate.dart';
import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'BookDetail.dart';

String urlAdd = "https://shuapi.jiaston.com/BookAction.aspx";

class SearchBarDelegate extends MySearchDelegate<String> {
  List<Widget> t = [];

  @override
  ThemeData appBarTheme(BuildContext context) {
    // TODO: implement appBarTheme
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    return theme.copyWith(
      primaryColor: Colors.white,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
      primaryColorBrightness: Brightness.light,
      primaryTextTheme: theme.textTheme,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> i = [];
    if (SpUtil.haveKey('history')) {
      i = SpUtil.getStringList('history');
    }
    for (var ii = 0; ii < i.length; ii++) {
      if (i[ii] == query) {
        i.removeAt(ii);
      }
    }
    i.insert(0, query);
    SpUtil.putStringList('history', i.sublist(0, i.length > 6 ? 6 : i.length));
    return SearchResult(query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    getHistory();
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text('搜索历史'),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                        onPressed: () {
                          SpUtil.remove('history');
                          getHistory();
                        },
                        child: new Text('清空历史'))
                  ],
                ),
              ],
            ),
            Expanded(
              child: GridView.count(
                shrinkWrap: true,
                //水平子Widget之间间距
                crossAxisSpacing: 60.0,
                //垂直子Widget之间间距
                mainAxisSpacing: 20.0,
                //GridView内边距
                padding: EdgeInsets.all(10.0),
                //一行的Widget数量
                crossAxisCount: 3,
                //子Widget宽高比例
                childAspectRatio: 2.0,
                //子Widget列表
                children: t,
              ),
            ),
          ],
        ));
  }

  getHistory() {
    var history = SpUtil.getStringList('history');

    for (var i = 0; i < history.length; i++) {
      t.add(getItemContainer(history[i]));
    }
  }

  Widget getItemContainer(String item) {
    return Container(
      alignment: Alignment.center,
      child: FlatButton(
          onPressed: () async {
            query = item;
          },
          child: Text(item,
              style: TextStyle(color: Colors.blue, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis)),
    );
  }
}

class SearchResult extends StatefulWidget {
  String word;

  SearchResult(this.word);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SearchResultState();
  }
}

class _SearchResultState extends State<SearchResult>
    with AutomaticKeepAliveClientMixin {
  List<SearchItem> bks = [];
  int page = 1;
  Widget body;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    bks = [];
    page = 1;
    getSearchData();
    if (mounted) {
      setState(() {});
    }
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    page += 1;
    getSearchData();
    _refreshController.loadComplete();
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSearchData();
  }

  getSearchData() async {
    var _context = null;
    if (bks == null) {
      _context = context;
    }
    var url =
        'https://sou.jiaston.com/search.aspx?key=${this.widget.word}&page=$page&siteid=app2';

    Response res = await Util(_context).http().get(url);
    List data = jsonDecode(res.data)['data'];
    if (data.length == 0) {
      _refreshController.loadNoData();
    } else {
      data.forEach((f) {
        bks.add(SearchItem.fromJson(f));
      });
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // TODO: implement build
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus mode) {
          if (mode == LoadStatus.idle) {
          } else if (mode == LoadStatus.loading) {
            body = CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text("加载失败！点击重试！");
          } else if (mode == LoadStatus.canLoading) {
            body = Text("松手,加载更多!");
          } else {
            body = Text("到底了!");
          }
          return Center(
            child: body,
          );
        },
      ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView.builder(
        itemBuilder: (context, i) {
          var auth = bks[i].Author;
          var cate = bks[i].CName;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: new Row(
              children: <Widget>[
                new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Container(
                      padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                      child: new Image.network(
                        bks[i].Img,
                        height: 100,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    )
                  ],
                ),
                new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  verticalDirection: VerticalDirection.down,
                  // textDirection:,
                  textBaseline: TextBaseline.alphabetic,

                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                      child: new Text(
                        bks[i].Name,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                      child: new Text('$cate | $auth',
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                      child: new Text(bks[i].Desc,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      width: 270,
                    ),
                  ],
                ),
              ],
            ),
            onTap: () async {
              String url = 'https://shuapi.jiaston.com/info/${bks[i].Id}.html';

              Response future = await Util(context).http().get(url);

              var data = jsonDecode(future.data)['data'];
              BookInfo bookInfo = new BookInfo.fromJson(data);
              Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => new BookDetail(bookInfo)));
            },
          );
        },
        itemCount: bks.length,
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
