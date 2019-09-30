import 'dart:convert';

import 'package:PureBook/common/LoadDialog.dart';
import 'package:PureBook/common/util.dart';
import 'package:PureBook/model/BookInfo.dart';
import 'package:PureBook/model/SearchItem.dart';
import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'BookDetail.dart';

List<SearchItem> bks = [];
List<int> datas = [1, 2, 3, 4, 5, 6, 7, 8, 9];
String urlAdd = "https://shuapi.jiaston.com/BookAction.aspx";

class SearchBarDelegate extends SearchDelegate<String> {
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
    return buildSearchFutureBuilder(query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return new SearchSuggestion();
  }

  FutureBuilder<List<SearchItem>> buildSearchFutureBuilder(String key) {
    return new FutureBuilder<List<SearchItem>>(
        builder: (context, AsyncSnapshot<List<SearchItem>> async) {
          if (async.connectionState == ConnectionState.active ||
              async.connectionState == ConnectionState.waiting) {
            return new Center(
              child: new CircularProgressIndicator(),
            );
          }
          if (async.connectionState == ConnectionState.done) {
            if (async.hasError) {
              return new Center(
                child: new Text('Error:code '),
              );
            } else if (async.hasData) {
              List<SearchItem> bean = async.data;
              return new ListView.builder(
                itemBuilder: (context, i) {
                  var auth = bks[i].Author;
                  var cate = bks[i].CName;
                  return new GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: new Row(
                      children: <Widget>[
                        new Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            new Container(
                              padding:
                                  const EdgeInsets.only(left: 10.0, top: 10.0),
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
                              padding:
                                  const EdgeInsets.only(left: 10.0, top: 10.0),
                              child: new Text(
                                bks[i].Name,
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.only(left: 10.0, top: 10.0),
                              child: new Text('$cate | $auth',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey)),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.only(left: 10.0, top: 10.0),
                              child: new Text(bks[i].Desc,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                              width: 270,
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () async {
                      String url =
                          'https://shuapi.jiaston.com/info/${bks[i].Id}.html';
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return new LoadingDialog(
                              text: "加载中…",
                            );
                          });
                      Response future = await Util.dio.get(url);
                      Navigator.pop(context);
                      var data = jsonDecode(future.data)['data'];
                      BookInfo bookInfo = new BookInfo.fromJson(data);
                      Navigator.of(context).push(new MaterialPageRoute(
                          builder: (BuildContext context) =>
                              new BookDetail(bookInfo)));
                    },
                  );
                },
                itemCount: bks.length,
              );
            }
          }
        },
        future: getSearchData(key));
  }

  Future<List<SearchItem>> getSearchData(String key) async {
    Response res = await Util.dio.get(
        'https://sou.jiaston.com/search.aspx?key=$query&page=1&siteid=app2');

    List data = jsonDecode(res.data)['data'];
    bks = data.map((f) => new SearchItem.fromJson(f)).toList();
    return bks;
  }
}

class SearchSuggestion extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _SearchSuggestionState();
  }
}

class _SearchSuggestionState extends State<SearchSuggestion> {
  List<Widget> his = [];

  Widget getItemContainer(String item) {
    return Container(
      alignment: Alignment.center,
      child: new FlatButton(
          onPressed: () async {
            String url = 'https://shuapi.jiaston.com/info/$item.html';
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return new LoadingDialog(
                    text: "加载中…",
                  );
                });
            Response future = await Util.dio.get(url);
            Navigator.pop(context);
            var data = jsonDecode(future.data)['data'];
            BookInfo bookInfo = new BookInfo.fromJson(data);
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new BookDetail(bookInfo)));
          },
          child: Text(item,
              style: TextStyle(color: Colors.blue, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Text('搜索历史'),
                  ],
                ),
                new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    new FlatButton(
                        onPressed: () {
                          SpUtil.remove('history');
                          getHistory();
                        },
                        child: new Text('清空历史'))
                  ],
                ),
              ],
            ),
            GridView.count(
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
              children: his,
            ),
          ],
        ));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getHistory();
  }

  getHistory() {
    var history = SpUtil.getStringList('history');
    List<Widget> t = [];
    for (var i = 0; i < history.length; i++) {
      t.add(getItemContainer(history[i]));
    }
    setState(() {
      his = t;
    });
  }
}
