import 'dart:convert';

import 'package:PureBook/common/Rating.dart';
import 'package:PureBook/common/common.dart';
import 'package:PureBook/common/util.dart';
import 'package:PureBook/entity/Book.dart';
import 'package:PureBook/entity/BookInfo.dart';
import 'package:PureBook/entity/ChapterList.dart';
import 'package:PureBook/event/event.dart';
import 'package:PureBook/model/ThemeModel.dart';
import 'package:PureBook/store/Store.dart';
import 'package:PureBook/view/ReadBook.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

import '../main.dart';



class BookDetail extends StatefulWidget {
  BookInfo _bookInfo;

  BookDetail(this._bookInfo);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _BookDetailState(_bookInfo);
  }
}

class _BookDetailState extends State<BookDetail>
    with AutomaticKeepAliveClientMixin {
  BookInfo _bookInfo;
  List<int> ids = [];
  List<Book> bs = [];
  bool inShelf = false;
  bool down = false;
  BannerAd _myBanner;
  MobileAdTargetingInfo _targetingInfo;
  _BookDetailState(this._bookInfo);

  @override
  Widget build(BuildContext context) {
    FirebaseAdMob.instance
        .initialize(appId: "ca-app-pub-6006602100377888~3769076624").then((res){
      _myBanner..load()..show();
    });
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Store.value<AppThemeModel>(context)
              .getThemeData()
              .iconTheme
              .color,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: Color.fromARGB(1, 245, 245, 245),
        actions: <Widget>[
          MaterialButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => MainPage()));
            },
            child: Text(
              "书架",
              style: TextStyle(
                  color: Store.value<AppThemeModel>(context)
                      .getThemeData()
                      .iconTheme
                      .color),
            ),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: Row(children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(
                        left: 10.0, top: 10.0, bottom: 10.0),
                    child: new Image.network(
                      Common.imgPre + _bookInfo.Img,
                      height: 100,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                verticalDirection: VerticalDirection.down,
                // textDirection:,
                textBaseline: TextBaseline.alphabetic,

                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(left: 20.0, top: 5.0),
                    child: new Text(
                      _bookInfo.Name,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 20.0, top: 2.0),
                    child: new Text('作者: ' + _bookInfo.Author,
                        style: TextStyle(fontSize: 12)),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 20.0, top: 2.0),
                    child: new Text('类型: ' + _bookInfo.CName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(fontSize: 12)),
                    width: 270,
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 20.0, top: 2.0),
                    child: new Text('状态: ' + _bookInfo.BookStatus,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(fontSize: 12)),
                    width: 270,
                  ),
                  Container(
                      padding: const EdgeInsets.only(
                          left: 15.0, top: 2.0, bottom: 10.0),
                      child: Row(
                        children: <Widget>[
                          Rating(
                            initialRating: _bookInfo.BookVote.Score.toInt(),
                          ),
                          Text(
                            '${_bookInfo.BookVote.Score}分',
                          )
                        ],
                      )),
                ],
              ),
            ]),
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  verticalDirection: VerticalDirection.down,
                  // textDirection:,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 17.0, top: 5.0),
                      child: new Text(
                        '简介',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 17.0, top: 5.0),
                      child: new Text(
                        _bookInfo.Desc,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                Divider(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  verticalDirection: VerticalDirection.down,
                  // textDirection:,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 17.0, top: 15.0),
                      child: new Text(
                        '目录',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    new ListTile(
                      trailing: Icon(Icons.keyboard_arrow_right),
                      leading: Icon(Icons.list),
                      title: new Text('最近更新: ' + _bookInfo.LastTime,
                          style: TextStyle(fontSize: 15)),
                      subtitle: new Text(_bookInfo.LastChapter),
                      onTap: () {
                        _bookInfo.CId = -1;
                        addToShelf();
                        Navigator.pop(context);
                        Navigator.of(context).push(new MaterialPageRoute(
                            builder: (BuildContext context) =>
                                new ReadBook(_bookInfo)));
                      },
                    ),
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 17.0, top: 5.0),
                      child: new Text(
                        '${_bookInfo.Author}  还写过',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true, //解决无限高度问题
                  physics: NeverScrollableScrollPhysics(), //禁用滑动事件
                  itemBuilder: (context, i) {
                    return new GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      child: new Container(
                        child: new Row(
                          children: <Widget>[
                            new Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                new Container(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, top: 10.0),
                                  child: new CachedNetworkImage(
                                    imageUrl: Common.imgPre +
                                        _bookInfo.SameUserBooks[i].Img,
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
                                    padding: const EdgeInsets.only(
                                        left: 10.0, top: 10.0),
                                    child: Text(
                                      _bookInfo.SameUserBooks[i].Name,
                                      style: TextStyle(
                                          color: Store.value<AppThemeModel>(context)
                                              .getThemeData()
                                              .iconTheme
                                              .color, fontSize: 18.0),
                                    )),
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, top: 10.0),
                                  child: new Text(
                                    _bookInfo.SameUserBooks[i].Author,
                                    style: TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, top: 10.0),
                                  child: new Text(
                                      _bookInfo.SameUserBooks[i].LastChapter,
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 11)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      onTap: () async {
                        String url =
                            'https://shuapi.jiaston.com/info/${_bookInfo.SameUserBooks[i].Id}.html';

                        Response future = await Util(context).http().get(url);
                        Navigator.pop(context);
                        var data = jsonDecode(future.data)['data'];
                        BookInfo bookInfo = new BookInfo.fromJson(data);
                        Navigator.pop(context);

                        Navigator.of(context).push(new MaterialPageRoute(
                            builder: (BuildContext context) =>
                                new BookDetail(bookInfo)));
                      },
                    );
                  },
                  itemCount: _bookInfo.SameUserBooks.length,
                ),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        //底部导航栏的创建需要对应的功能标签作为子项，这里我就写了3个，每个子项包含一个图标和一个title。
        items: [
          !ids.contains(_bookInfo.Id)
              ? BottomNavigationBarItem(
                  icon: Icon(
                    Icons.playlist_add,
                  ),
                  title: new Text(
                    '加入书架',
                  ))
              : BottomNavigationBarItem(
                  icon: Icon(
                    Icons.clear,
                  ),
                  title: new Text(
                    '移除书架',
                  )),
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("images/read.png"),
              ),
              title: new Text(
                '立即阅读',
              )),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.cloud_download,
                color: down ? Colors.lightBlue : Colors.black,
              ),
              title: new Text(
                '全本缓存',
              )),
        ],

        onTap: (int i) {
          switch (i) {
            case 0:
              {
                addToShelf();
              }
              break;
            case 1:
              {
                addToShelf();
                Navigator.pop(context);
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) =>
                        new ReadBook(_bookInfo)));
              }
              break;
            case 2:
              {
                setState(() {
                  down = true;
                });
                downAll();
              }
              break;
          }
        },
      ),
    );
  }

  addToShelf() {
    Util(null).http().post(Common.bookAction,
        data: {'action': 'addbookcase', 'bookId': _bookInfo.Id}).then((v) {
      print(v.data);
    });

    setState(() {
      if (ids.contains(_bookInfo.Id)) {
        bs.removeAt(ids.indexOf(_bookInfo.Id));
        ids.remove(_bookInfo.Id);
      } else {
        ids.add(_bookInfo.Id);
        bs.insert(
            0,
            new Book(
                0,
                '',
                0,
                _bookInfo.Id,
                _bookInfo.Name,
                _bookInfo.Author,
                _bookInfo.Img,
                _bookInfo.LastChapterId,
                _bookInfo.LastChapter,
                _bookInfo.LastTime));
      }

      SpUtil.putString(Common.listbookname, jsonEncode(bs));
    });
    eventBus.fire(new BooksEvent(bs));
  }

  downAll() async {
    setState(() {
      ids.add(_bookInfo.Id);
      bs.insert(
          0,
          new Book(
              0,
              '',
              0,
              _bookInfo.Id,
              _bookInfo.Name,
              _bookInfo.Author,
              _bookInfo.Img,
              _bookInfo.LastChapterId,
              _bookInfo.LastChapter,
              _bookInfo.LastTime));
      SpUtil.putString(Common.listbookname, jsonEncode(bs));
    });
    var url = Common.chaptersUrl + _bookInfo.Id.toString() + '/';

    Response response = await Util(null).http().get(url);

    String data = response.data;

    String replace = data.replaceAll('},]', '}]');
    var jsonDecode3 = jsonDecode(replace)['data'];
    List jsonDecode2 = jsonDecode3['list'];

    var list = jsonDecode2.map((m) => new ChapterList.fromJson(m)).toList();
    for (var i = 0; i < list.length; i++) {
      var list2 = list[i].list;
      for (var j = 0; j < list2.length;) {
        var cpt = list2[j];
        if ((!SpUtil.haveKey(cpt.id.toString())) && cpt.hasContent != 0) {
          var url = Common.bookContentUrl +
              _bookInfo.Id.toString() +
              "/" +
              cpt.id.toString() +
              ".html";
          Response response = await Util(null).http().get(url);
          String content = jsonDecode(response.data)['data']['content'];
          content = content
              .replaceAll("\r\n　　\r\n", "\n")
              .replaceAll('“', '')
              .replaceAll('”', '');
          if (content.startsWith("\r\n")) {
            content = content.substring(4).trim();
          }
          if (content.startsWith('\n')) {
            content = content.substring(1);
          }
          SpUtil.putString(cpt.id.toString(), content);
          cpt.hasContent = 2;
          print('${cpt.name} 下载成功');
        }
        j++;
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _myBanner.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    loadShlef();
//    getBookInfo();
  _targetingInfo= MobileAdTargetingInfo(
    keywords: <String>['games', 'pubg'],
    contentUrl: 'https://flutter.cn',

    childDirected: true,
 // or MobileAdGender.female, MobileAdGender.unknown
    testDevices: <String>[],
    // Android emulators are considered test devices
  );
  _myBanner=BannerAd(
    // Replace the testAdUnitId with an ad unit id from the AdMob dash.
    // https://developers.google.com/admob/android/test-ads
    // https://developers.google.com/admob/ios/test-ads
    adUnitId: 'ca-app-pub-6006602100377888/6756340222',
    size: AdSize.smartBanner,
    targetingInfo: _targetingInfo,
    listener: (MobileAdEvent event) {
      print("BannerAd event is $event");
    },
  );
  }

  Future loadShlef() async {
    var name = SpUtil.getString(Common.listbookname);
    List decode2 = json.decode(name);
    bs = decode2.map((m) => new Book.fromJson(m)).toList();
    ids = bs.map((f) => f.Id).toList();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
