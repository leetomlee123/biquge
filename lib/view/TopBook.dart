import 'dart:convert';

import 'package:PureBook/common/LoadDialog.dart';
import 'package:PureBook/common/common.dart';
import 'package:PureBook/common/util.dart';
import 'package:PureBook/model/BookInfo.dart';
import 'package:PureBook/model/TopBook.dart';
import 'package:PureBook/model/TopResult.dart';
import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'BookDetail.dart';

class TopBook extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _TopBookState();
  }
}

class _TopBookState extends State<TopBook> with AutomaticKeepAliveClientMixin {
  bool lv1 = true;
  bool lv2 = true;
  bool lv3 = true;
  Map word1 = {0: 'man', 1: 'lady'};
  Map word2 = {0: 'commend', 1: 'over', 2: 'collect', 3: 'new'};
  Map word3 = {0: 'week', 1: 'month', 2: 'total'};
  int idx1 = 0;
  int idx2 = 0;
  int idx3 = 0;
  List<TopBooks> items = [];
  TopResult topResult;
  int page = 1;
  bool hasNext = true;
  ScrollController _scrollController = new ScrollController();
  bool isPerformingRequest = false; // 是否有请求正在进行
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        getTop();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      /// 接口请求
      initUi();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // TODO: implement build
    return new Container(
      child: new Column(
        children: <Widget>[
          new Row(
            children: getBtnGroup(lv1, idx1, 0, ['男生', '女生']),
          ),
          new Row(
            children: getBtnGroup(lv2, idx2, 1, ['推荐', '完结', '收藏', '新书']),
          ),
          new Row(children: getBtnGroup(lv3, idx3, 2, ['周榜', ' 月榜', '总榜'])),
          Expanded(
              child: ListView.builder(
            controller: _scrollController,
            itemBuilder: (context, i) {
              var auth = items[i].Author;
              var cate = items[i].CName;
              if (i == items.length) {
                return _buildProgressIndicator();
              } else {
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
                              Common.imgPre + items[i].Img,
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
                              items[i].Name,
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
                            child: new Text(items[i].Desc,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            width: 270,
                          ),
                        ],
                      ),
                      new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                            items[i].Score.toString(),
                            style: TextStyle(
                                color: Colors.amberAccent, fontSize: 13.0),
                          ),
                        ],
                      )
                    ],
                  ),
                  onTap: () async {
                    String url =
                        'https://shuapi.jiaston.com/info/${items[i].Id}.html';
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
              }
            },
            itemCount: items.length,
          ))
        ],
      ),
    );
  }

  getBtnGroup(leve, idx, who, List<String> names) {
    List<Widget> btns = [];
    for (var i = 0; i < names.length; i++) {
      btns.add(new Padding(
        padding: const EdgeInsets.only(left: 5.0),
        child: new FlatButton(
            colorBrightness: Brightness.dark,
            textColor: Colors.black,
            highlightColor: Colors.grey,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            color: leve && i == idx ? Colors.grey : Colors.white,
            onPressed: () {
              setState(() {
                switch (who) {
                  case 0:
                    {
                      setState(() {
                        idx1 = i;
                        items = [];
                        isPerformingRequest = false;
                        hasNext = true;
                        page = 1;
                        getTop();
                      });
                    }
                    break;
                  case 1:
                    {
                      setState(() {
                        idx2 = i;
                        items = [];
                        isPerformingRequest = false;
                        hasNext = true;
                        page = 1;
                        getTop();
                      });
                    }
                    break;
                  case 2:
                    {
                      setState(() {
                        idx3 = i;
                        items = [];
                        isPerformingRequest = false;
                        hasNext = true;
                        page = 1;
                        getTop();
                      });
                    }
                    break;
                }
              });
            },
            child: new Text(names[i])),
      ));
    }
    return btns;
  }

  getTop() async {
    if (hasNext) {
      if (!isPerformingRequest) {
        // 判断是否有请求正在执行
        setState(() {
          isPerformingRequest = true;
          page += 1;
        });
        String url =
            '${Common.domain}/top/${word1[idx1]}/top/${word2[idx2]}/${word3[idx3]}/$page.html';
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return new LoadingDialog(
                text: "加载中…",
              );
            });
        Response res = await Util.dio.get(url);
        Navigator.pop(context);
        setState(() {
          topResult = new TopResult.fromJson(jsonDecode(res.data)['data']);

          items.addAll(topResult.BookList);
          isPerformingRequest = false;
          hasNext = topResult.HasNext;
        });
      }
    } else {
      double edge = 50.0;
      double offsetFromBottom = _scrollController.position.maxScrollExtent -
          _scrollController.position.pixels;
      if (offsetFromBottom < edge) {
        _scrollController.animateTo(
            _scrollController.offset - (edge - offsetFromBottom),
            duration: new Duration(milliseconds: 500),
            curve: Curves.easeOut);
      }
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isPerformingRequest ? 1.0 : 0.0,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  Future initUi() async {
    bool exist = SpUtil.haveKey(Common.toplist);
    if (exist) {
      var name = SpUtil.getString(Common.toplist);
      List decode2 = json.decode(name);
      setState(() {
        items = decode2.map((m) => new TopBooks.fromJson(m)).toList();
      });
    }
    String url =
        '${Common.domain}/top/${word1[0]}/top/${word2[0]}/${word3[0]}/$page.html';
    if (!exist) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return new LoadingDialog(
              text: "加载中…",
            );
          });
    }
    Response res = await Util.dio.get(url);
    if (!exist) {
      Navigator.pop(context);
    }
    topResult = new TopResult.fromJson(jsonDecode(res.data)['data']);
    if (exist) {
      SpUtil.remove(Common.toplist);
    }
    SpUtil.putString(Common.toplist, jsonEncode(topResult.BookList));
    setState(() {
      items = topResult.BookList;
      page = 2;
    });
  }
}
