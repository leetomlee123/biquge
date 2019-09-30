//import 'dart:convert';
//import 'dart:ui';
//
//import 'package:PureBook/common/common.dart';
//import 'package:PureBook/event/event.dart';
//import 'package:PureBook/model/Chapter.dart';
//import 'package:PureBook/model/ChapterList.dart';
//import 'package:dio/dio.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/gestures.dart';
//import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//
//var bookInfo = "https://shuapi.jiaston.com/info/";
//var chaptersUrl = "https://shuapi.jiaston.com/book/";
//var bookName = "";
//
//class ReadBook extends StatefulWidget {
//  String _bookId;
//
//  ReadBook(this._bookId);
//
//  @override
//  State<StatefulWidget> createState() {
//    // TODO: implement createState
//    return new ReadBookState(_bookId);
//  }
//}
//
//class ReadBookState extends State<ReadBook> {
//  String _bookId;
//  var bookInfo = 'https://shuapi.jiaston.com/info/';
//  var bookDetailUrl = 'https://shuapi.jiaston.com/book/';
//
//  //章节下标
//  int index = 0;
//  int _firstChapterId = 0;
//  var _curChapterId = 0;
//  var _lastChapterId = 10;
//  var content = "";
//  var chapterName = "";
//  var pageLen = 300;
//  var _fontSize = 20.0;
//  var pageIndex = 0;
//  List<String> contents = [" "];
//  List<Chapter> chapters = [];
//  List<String> chapterIds = [];
//
//  ReadBookState(this._bookId);
//
//  static GlobalKey<ScaffoldState> _globalKey = new GlobalKey();
//
//  @override
//  Widget build(BuildContext context) {
//    // TODO: implement build
//    return new Scaffold(
//        key: _globalKey,
//        drawer: new Drawer(
//          child: new ChapterView(chapters, _bookId, _curChapterId),
//        ),
//        appBar: new AppBar(
//          automaticallyImplyLeading: false,
//          elevation: 0,
//          backgroundColor: Color(0xFFFFEECC),
//          title: new Text(
//            chapterName == null ? "" : chapterName,
//            style: TextStyle(fontSize: _fontSize, color: Colors.black),
//          ),
//        ),
//        body: new GestureDetector(
//          behavior: HitTestBehavior.opaque,
//          onTapDown: (TapDownDetails details) {
//            changePage(context, details);
//          },
//          child: new Container(
//              color: Color(0xFFFFEECC),
//              //让容器占满全屏
//              height: double.infinity,
//              width: double.infinity,
//              padding: EdgeInsets.all(15),
//              child: new Text(
//                contents[pageIndex],
//                style: TextStyle(fontSize: _fontSize),
//                softWrap: true,
//              )),
//        ));
//  }
//
//  @override
//  initState() {
//    // TODO: implement initState
//    eventBus
//        .on<ChapterEvent>()
//        .listen((ChapterEvent data) => freshUi(data.chapterId));
//    initUi();
//  }
//
//  initUi() async {
//    SharedPreferences pfs = await SharedPreferences.getInstance();
////获取最新本书firstchapter lastchapter
//    if (_firstChapterId > 0 && _lastChapterId > 0) {
//    } else {
//      await getBookInfos();
//      pfs.setString(_bookId + "start", _firstChapterId.toString());
//      pfs.setString(_bookId + "last", _lastChapterId.toString());
//    }
//
////获取本书的阅读记录 并加载数据渲染ui
//    await getBookInfo();
//    //加载所有的章节 章节id并不是递增的 所以要先保存下来
//    await initChapters();
//  }
//
//  void initChapters() async {
//    //是否本地已有记录
//    await getLocalChapters();
//    //网络获取最新章节并更新
//    await loadChapters();
//    //初始化章节下标
//    for (var i = 0; i < chapters.length; i++) {
//      if (chapters[i].id == _curChapterId) {
//        index = i;
//      }
//    }
//  }
//
//  loadChapters() async {
//    var url = chaptersUrl + _bookId + '/';
//
//    Response response = await Util.dio.get(url);
//
//    String data = response.data;
//
//    String replace = data.replaceAll('},]', '}]');
//    var jsonDecode3 = jsonDecode(replace)['data'];
//    List jsonDecode2 = jsonDecode3['list'];
//    List<Chapter> temp = [];
//    var list = jsonDecode2.map((m) => new ChapterList.fromJson(m)).toList();
//    SharedPreferences preferences = await SharedPreferences.getInstance();
//    //第一次加载章节
//    for (var i = 0; i < list.length; i++) {
//      //目录名hasContent=0
//      temp.add(new Chapter(0, 0, list[i].name));
//      var list2 = list[i].list;
//      for (var j = 0; j < list2.length; j++) {
//        if (preferences.containsKey(list2[j].id.toString())) {
//          //标志 缓存2 当前章节已缓存
//          temp.add(new Chapter(2, list2[j].id, list2[j].name));
//        } else {
//          //未缓存
//          temp.add(new Chapter(1, list2[j].id, list2[j].name));
//        }
//      }
//    }
//    //如果有更新 用原来章节覆盖最新获取章节
//    if (chapters.isNotEmpty && temp.length - chapters.length > 0) {
//      temp.setAll(0, chapters);
//    }
//    if (mounted) {
//      setState(() {
//        chapters = temp;
//        if (preferences.containsKey(_bookId + 'chapters')) {
//          preferences.remove(_bookId + 'chapters');
//        }
//        preferences.setString(_bookId + 'chapters', json.encode(chapters));
//        //有可能bookinfo 获取的first last是错的 以chapters为准
//        for (var i = 0; i < chapters.length; i++) {
//          if (chapters[i].hasContent == 1) {
//            _firstChapterId = chapters[i].id;
//            _lastChapterId = chapters.last.id;
//            preferences.setString(
//                _bookId + "start", _firstChapterId.toString());
//            preferences.setString(_bookId + "last", _lastChapterId.toString());
//            break;
//          }
//        }
//        bookName = jsonDecode3['name'];
//      });
//    }
//  }
//
//  getLocalChapters() async {
//    SharedPreferences preferences = await SharedPreferences.getInstance();
//    if (preferences.containsKey(_bookId + 'chapters')) {
//      if (mounted) {
//        setState(() {
//          List data = json.decode(preferences.getString(_bookId + 'chapters'));
//          chapters = data.map((f) => new Chapter.fromJson(f)).toList();
//        });
//      }
//    }
//  }
//
//  freshUi(int pageNum) {
//    if (mounted) {
//      setState(() {
//        _curChapterId = pageNum;
//        for (var i = 0; i < chapters.length; i++) {
//          if (chapters[i].id == _curChapterId) {
//            index = i;
//          }
//        }
//        pageIndex = 0;
//        loadChapter(1);
//        saveRecord(pageIndex);
//      });
//    }
//  }
//
////从目录中查找上下章节的id id并不是连续的不能+-1 来获取
//  getChapterId(f) {
//    setState(() {
//      //f==1 next chpaterid f==0 pre chapterid
//      int id = 0;
//      if (f == 1) {
//        id = chapters[index + 1].id;
//        index += 1;
//      } else {
//        id = chapters[index - 1].id;
//        index -= 1;
//      }
//      _curChapterId = id;
//    });
//  }
//
////上一章 下一章
//  void changePage(BuildContext context, TapDownDetails details) {
//    var wid = MediaQuery.of(context).size.width;
//    var hei = MediaQuery.of(context).size.height;
//    var space = wid / 3;
//    var spaceY = hei / 3;
//    var curWid = details.localPosition.dx;
//    var curHeg = details.localPosition.dy;
//
//    setState(() {
//      if (curWid > 0 && curWid < space) {
//        var temp = pageIndex - 1;
//        if (temp >= 0) {
//          pageIndex = temp;
//          saveRecord(pageIndex);
//        } else {
//          getChapterId(0);
//          loadChapter(0);
//        }
//      } else if ((curWid > space && curWid < 2 * space) &&
//          (curHeg < 2 * spaceY)) {
//        //弹出底部栏
//        showModalBottomSheet(
//            context: context,
//            builder: (BuildContext bc) {
//              return new Column(
//                mainAxisSize: MainAxisSize.min,
//                children: <Widget>[
//                  new Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceAround,
//                    children: <Widget>[
//                      new FlatButton(
//                        color: Colors.blue,
//                        textColor: Colors.white,
//                        child: new Text('上一章'),
//                        onPressed: () {
//                          getChapterId(0);
//                          pageIndex = 0;
//                          loadChapter(1);
//                        },
//                      ),
//
//                      new MaterialButton(
//                        color: Colors.blue,
//                        textColor: Colors.white,
//                        child: new Text('下一章'),
//                        onPressed: () {
//                          getChapterId(1);
//                          pageIndex = 0;
//                          loadChapter(1);
//                        },
//                      )
//                    ],
//                  ),
//                  new Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                    children: <Widget>[
//                      new MaterialButton(
//                        color: Colors.blue,
//                        textColor: Colors.white,
//                        child: new Text('目录'),
//                        onPressed: () {
//                          Navigator.pop(context);
//                          _globalKey.currentState.openDrawer();
//                        },
//                      ),
//                      new MaterialButton(
//                        color: Colors.blue,
//                        textColor: Colors.white,
//                        child: new Text('缓存'),
//                        onPressed: () {
//                          showModalBottomSheet(
//                              context: context,
//                              builder: (BuildContext bc) {
//                                return new Column(
//                                    mainAxisSize: MainAxisSize.min,
//                                    children: <Widget>[
//                                      new Row(
//                                        mainAxisAlignment:
//                                            MainAxisAlignment.spaceAround,
//                                        children: <Widget>[
//                                          new MaterialButton(
//                                            color: Colors.blue,
//                                            textColor: Colors.white,
//                                            child: new Text('从当前章节缓存'),
//                                            onPressed: () {
//                                              downloadChapters(_curChapterId,
//                                                  _lastChapterId);
//                                              Navigator.pop(context);
//                                            },
//                                          ),
//                                        ],
//                                      ),
//                                      new Row(
//                                        mainAxisAlignment:
//                                            MainAxisAlignment.spaceAround,
//                                        children: <Widget>[
//                                          new MaterialButton(
//                                            color: Colors.blue,
//                                            textColor: Colors.white,
//                                            child: new Text('全本缓存'),
//                                            onPressed: () {
//                                              downloadChapters(_firstChapterId,
//                                                  _lastChapterId);
//                                              Navigator.pop(context);
//                                            },
//                                          )
//                                        ],
//                                      )
//                                    ]);
//                              });
//                        },
//                      ),
//                      new MaterialButton(
//                        color: Colors.blue,
//                        textColor: Colors.white,
//                        child: new Text('设置'),
//                        onPressed: () {},
//                      ),
//                    ],
//                  )
//                ],
//              );
//            });
//      } else {
//        var temp = pageIndex + 1;
//        if (temp < contents.length) {
//          pageIndex = temp;
//          saveRecord(pageIndex);
//        } else {
//          getChapterId(1);
//          loadChapter(1);
//        }
//      }
//    });
//  }
//
//  void saveRecord(b) {
//    //保存读书记录
//    Future<SharedPreferences> preferences = SharedPreferences.getInstance();
//    preferences
//        .then((value) => {value.setString(_bookId, '$_curChapterId-$b')});
//  }
//
//  downloadChapters(start, end) async {
//    //检查是否本地已有本书所有章节
//    List<Chapter> cps = [];
//    SharedPreferences preferences = await SharedPreferences.getInstance();
//
//    List data = json.decode(preferences.getString(_bookId + 'chapters'));
//    cps = data.map((f) => new Chapter.fromJson(f)).toList();
//    int cur = 0;
//    //hasContent=0 是卷名
//    if (_curChapterId == start) {
//      cur = index;
//    }
//    if (cps[cur].hasContent > 0) {
//      var url =
//          bookDetailUrl + _bookId + "/" + cps[cur].id.toString() + ".html";
//      Response response;
//      try {
//        response = await Util.dio.get(url);
//      } catch (e) {
//        print(e);
//      }
//      down(response, "", [], preferences, cps[cur].id);
//      print('download success 第 ${cps[cur].id} 章');
//      //2 表示已缓存
//      cps[cur].hasContent = 2;
//      setState(() {
//        chapters = cps;
//      });
//    }
//
//    //
//    preferences.remove(_bookId + 'chapters');
//    preferences.setString(_bookId + 'chapters', json.encode(cps));
//  }
//
////本地读书记录
//  getBookInfo() async {
//    SharedPreferences preferences = await SharedPreferences.getInstance();
//    if (preferences.containsKey(_bookId)) {
//      String name = preferences.get(_bookId);
//      List<String> split = name.split('-');
//      setState(() {
//        _curChapterId = int.parse(split[0]);
//        pageIndex = int.parse(split[1]);
//        var stringList = preferences.getStringList(_curChapterId.toString());
//        stringList = stringList == null ? [" "] : stringList;
//        contents = stringList;
//        chapterName = preferences.getString(_curChapterId.toString() + "name");
//      });
//    } else {
//      loadChapter(1);
//    }
//  }
//
//  getBookInfos() async {
//    Response response = await Util.dio.get(bookInfo + _bookId + ".html");
//    var jsonDecode2 = jsonDecode(response.data)['data'];
//
//    if (mounted) {
//      setState(() {
//        _firstChapterId = jsonDecode2['FirstChapterId'];
//        _lastChapterId = jsonDecode2['LastChapterId'];
//        _curChapterId = _curChapterId == 0 ? _firstChapterId : _curChapterId;
//      });
//    }
//  }
//
//  loadChapter(flage) async {
//    if (flage == 1) {
//      await getBookChapter(1, 1);
//      getBookChapter(0, 1);
//    } else {
//      await getBookChapter(1, 0);
//      getBookChapter(0, 0);
//    }
//  }
//
////f 1 加载  g 1 前进
//  getBookChapter(f, g) async {
//    SharedPreferences preferences = await SharedPreferences.getInstance();
//    String name = "";
//    List<String> temp = [];
//    int id = _curChapterId;
//    //f==0 是预加载
//    if (f == 0) {
//      id += 1;
//    }
//    if (preferences.containsKey(id.toString())) {
//      temp = preferences.getStringList(id.toString());
//      name = preferences.get(id.toString() + "name");
//    } else {
//      var url = bookDetailUrl + _bookId + "/" + id.toString() + ".html";
//      if (f == 1) {
//        showDialog(
//            context: context,
//            barrierDismissible: false,
//            builder: (BuildContext context) {
//              return new LoadingDialog(
//                text: "小说加载中…",
//              );
//            });
//      }
//      Response response = await Util.dio.get(url);
//      if (f == 1) {
//        Navigator.pop(context);
//      }
//      name = down(response, name, temp, preferences, id);
//      //设置已缓存
//      for (var i = 0; i < chapters.length; i++) {
//        if (chapters[i].id == id) {
//          chapters[i].hasContent = 2;
//        }
//      }
//    }
//    if (f == 1) {
//      setState(() {
//        contents = temp;
//        chapterName = name;
//        if (g == 1) {
//          pageIndex = 0;
//          saveRecord(pageIndex);
//        } else {
//          pageIndex = contents.length - 1;
//          saveRecord(pageIndex);
//        }
//      });
//    }
//  }

//  String down(Response response, String name, List<String> temp,
//      SharedPreferences preferences, int id) {
//    content = jsonDecode(response.data)['data']['content'];
//    name = jsonDecode(response.data)['data']['cname'];
//    content = content.replaceAll("\r\n　　\r\n", "\n");
//    if (content.startsWith("\r\n")) {
//      content = content.substring(4).trim();
//    }
//    var start = 0;
//
//    var lens = content.length;
//    while (lens >= pageLen) {
//      temp.add(content.substring(start, start + pageLen));
//      start += pageLen;
//      lens -= pageLen;
//    }
//    temp.add(content.substring(start, content.length));
//
//    preferences.setStringList(id.toString(), temp);
//    preferences.setString(id.toString() + "name", name);
//    return name;
//  }
//}
//
//class ChapterView extends StatefulWidget {
//  List<Chapter> chapters = [];
//  String bookId;
//  int _curChapterId;
//
//  ChapterView(this.chapters, this.bookId, this._curChapterId);
//
//  @override
//  State<StatefulWidget> createState() {
//    // TODO: implement createState
//    return new ChapterViewItem(bookId, _curChapterId, chapters);
//  }
//}
//
//class ChapterViewItem extends State<ChapterView> {
//  List<Chapter> chapters = [];
//  String bookId;
//  int _curChapterId;
//  ScrollController _scrollController = new ScrollController();
//
//  double ITEM_HEIGH = 50.0;
//  int ii = 0;
//  bool up = false;
//  int curIndex = 0;
//
//  ChapterViewItem(this.bookId, this._curChapterId, this.chapters);
//
//  @override
//  void dispose() {
//    // TODO: implement dispose
//    super.dispose();
//    _scrollController.dispose();
//  }
//
//  @override
//  void initState() {
//    // TODO: implement initState
//    var widgetsBinding = WidgetsBinding.instance;
//    widgetsBinding.addPostFrameCallback((callback) {
//      scrollTo();
//    });
//  }
//
////滚动到当前阅读位置
//  scrollTo() async {
//    for (int i = 0; i < chapters.length; i++) {
//      if (chapters[i].id == _curChapterId) {
//        if (_scrollController.hasClients) {
//          curIndex = i - 8;
//          await _scrollController.animateTo((i - 8) * ITEM_HEIGH,
//              duration: new Duration(microseconds: 1), curve: Curves.ease);
//        }
//      }
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    // TODO: implement build
//    Widget listView = new ListView.builder(
//      controller: _scrollController,
//      itemExtent: ITEM_HEIGH,
//      itemBuilder: (context, index) {
//        var title = chapters[index].name;
//        var id = chapters[index].id;
//        var has = chapters[index].hasContent;
//        padding:
//        EdgeInsets.all(16.0);
//        return ListTile(
//          title: getTitle(title, has),
//          trailing: new Text(
//            has == 2 ? "已缓存" : "",
//            style: TextStyle(fontSize: 8, color: Colors.grey),
//          ),
//          selected: id == _curChapterId,
//          onTap: () {
//            if (has > 0) {
//              //不是卷目录
//              Navigator.of(context).pop();
//              eventBus.fire(new ChapterEvent(id));
//            }
//          },
//        );
//      },
//      itemCount: chapters.length,
//    );
//
//    return new Scaffold(
//      appBar: AppBar(
//        title: new Text("dd"),
//        automaticallyImplyLeading: false,
//        elevation: 0,
//        backgroundColor: Colors.white,
//      ),
//      body: Scrollbar(
//        child: listView,
//      ),
////      floatingActionButton: FloatingActionButton(
////          onPressed: scrollAdd,
////          child: Icon(up ? Icons.arrow_upward : Icons.arrow_downward)),
//    );
//  }
//
//  scrollAdd() async {
//    if (_scrollController.hasClients) {
//      await _scrollController.animateTo((curIndex += 8) * ITEM_HEIGH,
//          duration: new Duration(microseconds: 1), curve: Curves.ease);
//    }
//  }
//
//  getTitle(title, has) {
//    Widget widget;
//    if (has == 0) {
//      widget = new Text(
//        title,
//        style: TextStyle(
//            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
//      );
//    } else {
//      widget = new Text(
//        title,
//        style: TextStyle(fontSize: 12),
//      );
//    }
//    return widget;
//  }
//}
