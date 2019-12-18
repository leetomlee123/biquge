import 'dart:convert';

import 'package:PureBook/common/common.dart';
import 'package:PureBook/common/toast.dart';
import 'package:PureBook/common/util.dart';
import 'package:PureBook/entity/Book.dart';
import 'package:PureBook/entity/BookInfo.dart';
import 'package:PureBook/event/event.dart';
import 'package:PureBook/main.dart';
import 'package:PureBook/store/Store.dart';
import 'package:PureBook/view/MySearchDelegate.dart';
import 'package:PureBook/view/ReadBook.dart';
import 'package:PureBook/view/Search.dart';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
  Widget body;
  RefreshController _refreshController =
      RefreshController(initialRefresh: SpUtil.haveKey('login'));

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
    SpUtil.putString(Common.listbookname, jsonEncode(dataSource));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: Colors.black,
          icon: ImageIcon(
            AssetImage("images/account.png"),
          ),
          onPressed: () {
            eventBus.fire( OpenEvent(''));
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '书架',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              color: Colors.black,
              tooltip: '搜索小说',
              onPressed: () {
                myshowSearch(context: context, delegate: SearchBarDelegate());
              }),
        ],
      ),
      body: SmartRefresher(
        enablePullDown: true,
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
        onRefresh: freshShelf,
        child: ListView.builder(
            itemCount: dataSource.length,
            itemBuilder: (context, i) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    dataSource[i].NewChapterCount = 0;
                  });
                  Book temp = dataSource[i];
                  updateBookList(dataSource[i]);
                  Navigator.of(context).push(new MaterialPageRoute(
                      builder: (BuildContext context) =>
                          ReadBook(BookInfo.id(temp.Id, temp.Name))));
                },
                child: getBookItemView(dataSource[i]),
              );
            }),
      ),
    );
  }

//刷新书架
  freshShelf() async {
    if (SpUtil.haveKey('login')) {
      FormData formData = new FormData.fromMap({
        "password": SpUtil.getString('pwd'),
        "username": SpUtil.getString('username'),
        "usecookie": 43200,
        "action": "login",
      });
      Util(null).http().post(Common.login, data: formData);
    }
    //网络请求
    Response response2 =
        await Util(null).http().get(Common.domain + "/Bookshelf.aspx");
    List decode = json.decode(response2.data)['data'];
    bs = decode.map((m) => new Book.fromJson(m)).toList();
    List<Book> tps;
    if (dataSource.isNotEmpty) {
      tps = dataSource;
      for (var i = 0; i < tps.length; i++) {
        for (var j = 0; j < bs.length; j++) {
          if (tps[i].Id == bs[j].Id) {
            if (tps[i].LastChapter != bs[j].LastChapter) {
              tps[i].UpdateTime = bs[j].UpdateTime;
              tps[i].LastChapter = bs[j].LastChapter;
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
    _refreshController.refreshCompleted();
  }


  getBookItemView(Book item) {
    return Dismissible(
      key: Key(item.Id.toString()),
      child: Container(
        child: Row(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                  child: Stack(
                    children: <Widget>[
                      ExtendedImage.network(
                         Common.imgPre + item.Img,
                        height: 100,
                        width: 80,
                        fit: BoxFit.cover,
                        cache: true,
                      ),
                      item.NewChapterCount == 1
                          ? Container(
                        height: 100,
                        width: 80,
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Image.asset(
                                  'images/h6.png',
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                  child: Text(
                    item.Name,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                  child: Text(
                    item.LastChapter,
                    style: TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                  child: Text(item.UpdateTime,
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
            dataSource.removeAt(i);
            if (mounted) {
              setState(() {});
            }
            SpUtil.putString(Common.listbookname, jsonEncode(dataSource));
            Util(null).delLocalCache([item.Id.toString()]);
            break;
          }
        }
        Util(null).http().post(Common.bookAction,
            data: {'bookIds': item.Id, 'action': 'removebookcase'}).then((v) {
          Toast.show('删除成功');
        });
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
          _confirmContent = '确认删除     ${item.Name}';
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
        dataSource = books;
      });
      //先登录获取cookie

      freshShelf();
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
    //网络请求
    Response response2 =
        await Util(context).http().get(Common.domain + "/Bookshelf.aspx");
    List decode = json.decode(response2.data)['data'];
    books = decode.map((m) => Book.fromJson(m)).toList();
    var ids = dataSource.map((f) => f.Id).toList();
    books.forEach((f) {
      if (!ids.contains(f.Id)) {
        dataSource.insert(dataSource.length, f);
      }
    });
    if (mounted) {
      setState(() {});
    }
    SpUtil.putString(Common.listbookname, jsonEncode(dataSource));
  }
}
