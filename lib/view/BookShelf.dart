import 'dart:convert';

import 'package:PureBook/action/BookAction.dart';
import 'package:PureBook/common/LoadDialog.dart';
import 'package:PureBook/common/common.dart';
import 'package:PureBook/common/toast.dart';
import 'package:PureBook/common/util.dart';
import 'package:PureBook/event/event.dart';
import 'package:PureBook/main.dart';
import 'package:PureBook/model/Book.dart';
import 'package:PureBook/model/BookInfo.dart';
import 'package:PureBook/model/BookTag.dart';
import 'package:PureBook/view/ReadBook.dart';
import 'package:PureBook/view/Search.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

var map = {0: "我的书架", 1: "排行榜", 2: "我的"};
List<Book> bs = [];

class BookShelf extends StatefulWidget {
  BookShelf();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _BookShelfState();
  }
}

class _BookShelfState extends State<BookShelf>
    with AutomaticKeepAliveClientMixin {
  List<Book> dataSource = [];

  @override
  void initState() {
    eventBus
        .on<BooksEvent>()
        .listen((BooksEvent booksEvent) => fresh(booksEvent.books));
    eventBus
        .on<SyncShelfEvent>()
        .listen((SyncShelfEvent booksEvent) => loginSync());

    var widgetsBinding = WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((callback) {
      getBookList();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SpUtil.putString(Common.listbookname, jsonEncode(books));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // TODO: implement build
    var c = new ListView.builder(
        itemCount: dataSource.length,
        itemBuilder: (context, i) {
          return new GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
               dataSource[i].NewChapterCount=0;
              });
              Book temp = dataSource[i];
              updateBookList(dataSource[i]);
              Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) =>
                      new ReadBook(BookInfo.id(temp.Id, temp.Name))));
            },
            child: getBookItemView(dataSource[i]),
          );
        });
    var n = new Container(
      child: IconButton(
          icon: ImageIcon(
            AssetImage("images/add.png"),
          ),
          color: Colors.black,
          tooltip: '搜索小说',
          onPressed: () {
            showSearch(context: context, delegate: SearchBarDelegate());
          }),
    );

    return new RefreshIndicator(
      child: c,
      onRefresh: _onRefresh,
    );
  }

  Future<void> _onRefresh() async {
    freshShelf();
  }

//刷新书架
  freshShelf() async {
    //网络请求

    Response response2 = await Util.dio.get(Common.domain + "/Bookshelf.aspx");
    List decode = json.decode(response2.data)['data'];
    bs = decode.map((m) => new Book.fromJson(m)).toList();
    List<Book> tps;
    if (dataSource.isNotEmpty) {
      tps = dataSource;
      for (var i = 0; i < tps.length; i++) {
        for (var j = 0; j < bs.length; j++) {
          if (tps[i].Id == bs[j].Id) {
            if (tps[i].UpdateTime != bs[j].UpdateTime) {
              tps[i].UpdateTime = bs[j].UpdateTime;
              tps[i].NewChapterCount = 1;
            }
          }
        }
      }
    } else {
      tps = bs;
    }
    setState(() {
      dataSource = tps;
    });
    SpUtil.putString(Common.listbookname, jsonEncode(dataSource));
  }

  getBookItemView(Book item) {
    return Dismissible(
      key: Key(item.Id.toString()),
      child: new Container(
        child: new Row(
          children: <Widget>[
            new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Container(
                  padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                  child: new CachedNetworkImage(
                    imageUrl: Common.imgPre + item.Img,
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
                    child: RichText(
                      text: TextSpan(
                          text: item.Name,
                          style: TextStyle(color: Colors.black, fontSize: 18.0),
                          children: <TextSpan>[
                            TextSpan(
                                style: TextStyle(
                                    color: Colors.red, fontSize: 14.0),
                                text:
                                    '${item.NewChapterCount == 1 ? '(更新)' : ''}')
                          ]),
                    )),
                Container(
                  padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                  child: new Text(
                    item.LastChapter,
                    style: TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                  child: new Text(item.UpdateTime,
                      style: TextStyle(color: Colors.grey, fontSize: 11)),
                ),
              ],
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        for (var i = 0; i < dataSource.length; i++) {
          if (dataSource[i].Id == item.Id) {
            setState(() {
              dataSource.removeAt(i);
            });
            SpUtil.putString(Common.listbookname, jsonEncode(dataSource));
            for (var value in new BookTag.fromJson(
                    jsonDecode(SpUtil.getString(item.Id.toString())))
                .chapters) {
              SpUtil.remove(value.id.toString());
            }
            ;
            break;
          }
        }
      },
      background: Container(
        color: Colors.green,
        // 这里使用 ListTile 因为可以快速设置左右两端的Icon
        child: ListTile(
          leading: Icon(
            Icons.bookmark,
            color: Colors.white,
          ),
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        // 这里使用 ListTile 因为可以快速设置左右两端的Icon
        child: ListTile(
          trailing: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      confirmDismiss: (direction) async {
        var _confirmContent;

        var _alertDialog;

        if (direction == DismissDirection.endToStart) {
          // 从右向左  也就是删除
          _confirmContent = '确认删除${item.Name}？';
          _alertDialog = _createDialog(
            _confirmContent,
            () {
              // 展示 SnackBar
              Navigator.of(context).pop(true);
            },
            () {
              Navigator.of(context).pop(false);
            },
          );
        } else {
          return false;
        }
        var isDismiss = await showDialog(
            context: context,
            builder: (context) {
              return _alertDialog;
            });
        return isDismiss;
      },
    );
  }

  Widget _createDialog(
      String _confirmContent, Function sureFunction, Function cancelFunction) {
    return AlertDialog(
      content: Text(_confirmContent),
      actions: <Widget>[
        FlatButton(onPressed: sureFunction, child: Text('确定')),
        FlatButton(onPressed: cancelFunction, child: Text('取消')),
      ],
    );
  }

  updateBookList(Book item) async {
    for (var i = 0; i < dataSource.length; i++) {
      if (dataSource[i].Id == item.Id) {
        dataSource.removeAt(i);
        break;
      }
    }
    setState(() {
      dataSource.insert(0, item);
    });

    //存储到本地
    SpUtil.putString(Common.listbookname, json.encode(dataSource));
  }

  fresh(List<Book> books) {
    if (mounted) {
      setState(() {
        dataSource = books;
      });
    }
  }

  getBookList() async {
    if (SpUtil.haveKey(Common.listbookname)) {
      //先从本地缓存中拿
      var name = SpUtil.getString(Common.listbookname);
      List decode2 = json.decode(name);
      books = decode2.map((m) => new Book.fromJson(m)).toList();
      setState(() {
        dataSource=books;
      });
      //先登录获取cookie
      BookAction.action.login().whenComplete(() async {
        freshShelf();
      });
    } else {
      if (!SpUtil.haveKey('username')) {
        Toast.show('请登录后同步书架');
        return;
      }
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  loginSync() async {
    BookAction.action.login().whenComplete(() async {
      //网络请求
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return new LoadingDialog(
              text: "书架同步中…",
            );
          });
      Response response2 = await Util.dio.get(Common.domain + "/Bookshelf.aspx");
      Navigator.pop(context);

      List decode = json.decode(response2.data)['data'];
      books = decode.map((m) => new Book.fromJson(m)).toList();
      setState(() {
        dataSource.insertAll(dataSource.length, books);
      });
      SpUtil.putString(Common.listbookname, jsonEncode(dataSource));
    });

  }
}
