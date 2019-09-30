import 'dart:convert';

import 'package:PureBook/common/Rating.dart';
import 'package:PureBook/common/common.dart';
import 'package:PureBook/common/util.dart';
import 'package:PureBook/event/event.dart';
import 'package:PureBook/model/Book.dart';
import 'package:PureBook/model/BookInfo.dart';
import 'package:PureBook/model/Chapter.dart';
import 'package:PureBook/model/ChapterList.dart';
import 'package:PureBook/view/ReadBook.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

import '../common/LoadDialog.dart';
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

  _BookDetailState(this._bookInfo);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        elevation: 0,
        actions: <Widget>[
          new MaterialButton(
            onPressed: () {
              Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => MainPage()));
            },
            child: new Text("书架"),
          )
        ],
      ),
      body: new Column(
        children: <Widget>[
          new Container(
            color: Colors.grey,
            child: new Row(children: <Widget>[
              new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Container(
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
              new Column(
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
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 20.0, top: 2.0),
                    child: new Text('作者: ' + _bookInfo.Author,
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 20.0, top: 2.0),
                    child: new Text('类型: ' + _bookInfo.CName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                    width: 270,
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 20.0, top: 2.0),
                    child: new Text('状态: ' + _bookInfo.BookStatus,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                    width: 270,
                  ),
                  Container(
                      padding: const EdgeInsets.only(
                          left: 15.0, top: 2.0, bottom: 10.0),
                      child: new Row(
                        children: <Widget>[
                          Rating(
                            initialRating: _bookInfo.BookVote.Score.toInt(),
                          ),
                          new Text(
                            '${_bookInfo.BookVote.Score}分',
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      )),
                ],
              ),
            ]),
          ),
          new Column(
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
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              new Divider(),
              Padding(
                padding: const EdgeInsets.only(left: 17.0, top: 5.0),
                child: new Text(
                  _bookInfo.Desc,
                  style: TextStyle(fontSize: 12),
                ),
              ),
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
              Padding(
                padding: const EdgeInsets.only(left: 17.0, top: 15.0),
                child: new Text(
                  '目录',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(),
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
          new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 17.0, top: 5.0),
                child: new Text(
                  '${_bookInfo.Author}  还写过',
                  style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Divider(),
          Expanded(child: ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, i) {
              return new GestureDetector(behavior: HitTestBehavior.opaque, child: new Container(
                child: new Row(
                  children: <Widget>[
                    new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Container(
                          padding:
                          const EdgeInsets.only(left: 10.0, top: 10.0),
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
                                  color: Colors.black, fontSize: 18.0),
                            )),
                        Container(
                          padding:
                          const EdgeInsets.only(left: 10.0, top: 10.0),
                          child: new Text(
                            _bookInfo.SameUserBooks[i].Author,
                            style: TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding:
                          const EdgeInsets.only(left: 10.0, top: 10.0),
                          child: new Text(
                              _bookInfo.SameUserBooks[i].LastChapter,
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 11)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),onTap: () async {
                String url =
                    'https://shuapi.jiaston.com/info/${_bookInfo.SameUserBooks[i].Id}.html';
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
                Navigator.pop(context);

                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) =>
                    new BookDetail(bookInfo)));
              },);

            },
            itemCount: _bookInfo.SameUserBooks.length,
          )
            ,)
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

   addToShelf()  {
   Util.dio.post(Common.bookAction,data: {'action':'addbookcase','bookId':_bookInfo.Id}).then((v){
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

    Response response = await Util.dio.get(url);

    String data = response.data;

    String replace = data.replaceAll('},]', '}]');
    var jsonDecode3 = jsonDecode(replace)['data'];
    List jsonDecode2 = jsonDecode3['list'];
    List<Chapter> temp = [];
    var list = jsonDecode2.map((m) => new ChapterList.fromJson(m)).toList();
    for (var i = 0; i < list.length; i++) {
      //目录名hasContent=0
      temp.add(new Chapter(0, 0, list[i].name));
      var list2 = list[i].list;
      for (var j = 0; j < list2.length; j++) {
        var url =
            'https://shuapi.jiaston.com/book/${_bookInfo.Id}/${list2[j].id}.html';
        Response response = await Util.dio.get(url);
        String content = jsonDecode(response.data)['data']['content'];
        String name = jsonDecode(response.data)['data']['cname'];
        content = content.replaceAll("\r\n　　\r\n", "\n");
        if (content.startsWith("\r\n")) {
          content = content.substring(4).trim();
        }
        List<String> contents = [];
        var start = 0;
        var pageLen = 300;
        var lens = content.length;
        while (lens >= pageLen) {
          contents.add(content.substring(start, start + pageLen));
          start += pageLen;
          lens -= pageLen;
        }
        contents.add(content.substring(start, content.length));

        SpUtil.putStringList(list2[j].id.toString(), contents);
        SpUtil.putString(list2[j].id.toString() + "name", name);
        //标志 缓存2 当前章节已缓存
        temp.add(new Chapter(2, list2[j].id, list2[j].name));
      }
      SpUtil.putString(_bookInfo.Id.toString() + 'chapters', jsonEncode(temp));
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    loadShlef();
//    getBookInfo();
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
