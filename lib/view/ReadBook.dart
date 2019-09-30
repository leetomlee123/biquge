import 'dart:convert';

import 'package:PureBook/common/LoadDialog.dart';
import 'package:PureBook/common/common.dart';
import 'package:PureBook/common/toast.dart';
import 'package:PureBook/common/util.dart';
import 'package:PureBook/event/event.dart';
import 'package:PureBook/model/BookInfo.dart';
import 'package:PureBook/model/BookTag.dart';
import 'package:PureBook/model/Chapter.dart';
import 'package:PureBook/model/ChapterList.dart';
import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReadBook extends StatefulWidget {
  BookInfo _bookInfo;

  ReadBook(this._bookInfo);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _ReadBookState(_bookInfo);
  }
}

class _ReadBookState extends State<ReadBook> {
  BookInfo _bookInfo;
  BookTag _bookTag;
  static GlobalKey<ScaffoldState> _globalKey = new GlobalKey();
  String content = '';
  double contentH;
  double contentW;

  _ReadBookState(this._bookInfo);

  List<String> contents = [""];
  List<Chapter> chapters = [];

  int first = 0;
  int last = 0;

  //控件value
  double value = 0.0;
// 初始opacityLevel为1.0为可见状态，为0.0时不可见
  double opacityLevel = 1.0;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SpUtil.putString(_bookInfo.Id.toString(), jsonEncode(_bookTag));
  }

  @override
  void initState() {
    eventBus
        .on<ChapterEvent>()
        .listen((ChapterEvent data) => freshUi(data.chapterId));

    getBookRecord();

    var widgetsBinding = WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((callback) {
      asyncInit();
      contentH = ScreenUtil.getScreenH(context) - 60;
      contentH = ScreenUtil.getScreenW(context) - 30;
    });
  }
  _changeOpacity() {
    //调用setState（）  根据opacityLevel当前的值重绘ui
    // 当用户点击按钮时opacityLevel的值会（1.0=>0.0=>1.0=>0.0 ...）切换
    // 所以AnimatedOpacity 会根据opacity传入的值(opacityLevel)进行重绘 Widget
    setState(
            () => opacityLevel = opacityLevel == 0 ? 1.0 : 0.0
    );
  }
  asyncInit() async {
    await getChapters();
    await loadChapter(1);
  }

  freshUi(int cur) {
    if (mounted) {
      setState(() {
        value = cur.toDouble();
        _bookTag.cur = cur;
        _bookTag.index = 0;
        loadChapter(1);
      });
    }
  }

//获取本书记录
  getBookRecord() async {
    if (SpUtil.haveKey(_bookInfo.Id.toString())) {
      //本书已读过
      setState(() {
        _bookTag = new BookTag.fromJson(
            jsonDecode(SpUtil.getString(_bookInfo.Id.toString())));
        chapters = _bookTag.chapters;
        contents = _bookTag.contents;
        //slider value
        value = _bookTag.cur.toDouble();
        if (_bookTag.index >= contents.length) {
          _bookTag.index = contents.length - 1;
        }
      });
    } else {
      last = _bookInfo.LastChapterId;
      first = _bookInfo.FirstChapterId;
      _bookTag = new BookTag(_bookInfo.FirstChapterId, _bookInfo.LastChapterId,
          0, 0, chapters, _bookInfo.Name, contents);
    }
  }

  getBookInfo() async {
    Response response =
        await Util.dio.get(Common.bookInfo + _bookInfo.Id.toString() + ".html");
    var jsonDecode2 = jsonDecode(response.data)['data'];
    _bookInfo.FirstChapterId = jsonDecode2['FirstChapterId'];
    first = _bookInfo.FirstChapterId;
    _bookInfo.LastChapterId = jsonDecode2['LastChapterId'];
    last = _bookInfo.LastChapterId;
  }

  getChapters() async {
    var url = Common.chaptersUrl + _bookInfo.Id.toString() + '/';
    if (!SpUtil.haveKey(_bookInfo.Id.toString())) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return new LoadingDialog(
              text: "章节加载中…",
            );
          });
    }
    Response response = await Util.dio.get(url);
    if (!SpUtil.haveKey(_bookInfo.Id.toString())) {
      Navigator.pop(context);
    }
    String data = response.data;
    String replace = data.replaceAll('},]', '}]');
    var jsonDecode3 = jsonDecode(replace)['data'];
    List jsonDecode2 = jsonDecode3['list'];
    List<Chapter> temp = [];
    var list = jsonDecode2.map((m) => new ChapterList.fromJson(m)).toList();
    //第一次加载章节
    for (var i = 0; i < list.length; i++) {
      //目录名hasContent=0
      temp.add(new Chapter(0, 0, list[i].name));
      var list2 = list[i].list;
      for (var j = 0; j < list2.length; j++) {
        temp.add(new Chapter(1, list2[j].id, list2[j].name));
      }
    }
    temp.setAll(0, chapters);
    setState(() {
      chapters = temp;
      _bookTag.chapters = temp;
      SpUtil.putString(_bookInfo.Id.toString(), jsonEncode(_bookTag));
      //书的最后一章
      if (_bookInfo.CId == -1) {
        _bookTag.cur = chapters.length - 1;
        value = _bookTag.cur.toDouble();
      }
    });
  }

  loadChapter(flage) async {
    if (flage == 1) {
      await getBookChapter(1, 1);
      getBookChapter(0, 1);
    } else {
      getBookChapter(1, 0);
      getBookChapter(0, 0);
    }
  }

//f 1 加载  g 1 前进
  getBookChapter(f, g) async {
    int id = 0;
    //f==0 是预加载
    if (f == 0) {
      int temp = _bookTag.cur + 1;
      if (temp == chapters.length) {
        return;
      }
      var chapter = chapters[temp];
      while (chapter.hasContent == 0) {
        temp += 1;
        chapter = chapters[temp];
      }
      id = chapter.id;
    } else {
      var chapter = chapters[_bookTag.cur];
      while (chapter.hasContent == 0) {
        _bookTag.cur += 1;
        chapter = chapters[_bookTag.cur];
      }
      id = chapter.id;
    }

    downChapter(id, f, _bookTag.cur);

    if (g == 0) {
      _bookTag.index = contents.length - 1;
    }
  }

  justDown(id) async {
    if (!SpUtil.haveKey(id.toString())) {
      var url = Common.bookContentUrl +
          _bookInfo.Id.toString() +
          "/" +
          id.toString() +
          ".html";
      Response response = await Util.dio.get(url);
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
      var start = 0;
      List<String> temp = [];
      var lens = content.length;
      while (lens >= _bookTag.pageLen) {
        temp.add(content.trim().substring(start, start + _bookTag.pageLen));
        start += _bookTag.pageLen;
        lens -= _bookTag.pageLen;
      }

      temp.add(content.substring(start, content.length));
      SpUtil.putStringList(id.toString(), temp);
    }
  }

//按照chapterid下载
  downChapter(int id, f, i) async {
    if (SpUtil.haveKey(id.toString())) {
      if (f != 0) {
        setState(() {
          contents = SpUtil.getStringList(id.toString());
          _bookTag.contents = contents;
        });
      }
      return;
    }
    var url = Common.bookContentUrl +
        _bookInfo.Id.toString() +
        "/" +
        id.toString() +
        ".html";
    if (f == 1) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return new LoadingDialog(
              text: "正文加载中…",
            );
          });
    }
    Response response = await Util.dio.get(url);
    if (f == 1) {
      Navigator.pop(context);
    }
    if (mounted) {
      setState(() {
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
        var start = 0;
        List<String> temp = [];
        var lens = content.length;
        while (lens >= _bookTag.pageLen) {
          temp.add(content.trim().substring(start, start + _bookTag.pageLen));
          start += _bookTag.pageLen;
          lens -= _bookTag.pageLen;
        }

        temp.add(content.substring(start, content.length));
        if (f == 1) {
          _bookTag.content = content;
          contents = temp;
        }
//        _bookTag.contents = cs;
        SpUtil.putStringList(id.toString(), temp);
        chapters[i].hasContent = 2;
      });
    }
  }

//上一章 下一章
  void changePage(BuildContext context, TapDownDetails details) {
    var wid = MediaQuery.of(context).size.width;
    var hei = MediaQuery.of(context).size.height;
    var space = wid / 3;
    var spaceY = hei / 3;
    var curWid = details.localPosition.dx;
    var curHeg = details.localPosition.dy;

    setState(() {
      if (curWid > 0 && curWid < space) {
        var temp = _bookTag.index - 1;
        if (temp >= 0) {
          _bookTag.index = temp;
        } else {
          int temp = _bookTag.cur - 1;

          if (temp < 0) {
            Toast.show('已经是第一页');
          } else {
            _bookTag.cur -= 1;
            loadChapter(0);
          }
        }
      } else if ((curWid > space && curWid < 2 * space) &&
          (curHeg < 2 * spaceY)) {
        //弹出底部栏
        showModalBottomSheet(
            context: context,
            builder: (BuildContext bc) {
              return StatefulBuilder(
                builder: (context, state) {
                  return new Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          InkWell(
                            child: Container(
                              alignment: Alignment.center,
                              height: 50,
                              child: Text(
                                "上一章",
                                maxLines: 1,
                                style: TextStyle(color: Colors.blue),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: () {
                              _bookTag.index = 0;
                              _bookTag.cur -= 1;
                              loadChapter(1);
                            },
                          ),
                          Slider(
                            value: value,
                            max: (chapters.length - 1).toDouble(),
                            min: 0.0,
                            onChanged: (newValue) {
                              state(() {
                                int temp = newValue.round();
                                value = temp.toDouble();
                                _bookTag.cur = temp;
                                downChapter(chapters[temp].id, 1, temp);
                              });
                            },
                            label: '${chapters[_bookTag.cur].name} ',
                            divisions: chapters.length,
                            semanticFormatterCallback: (newValue) {
                              return '${newValue.round()} dollars';
                            },
                            activeColor: Colors.lightBlue,
                            inactiveColor: Colors.grey,
                          ),
                          InkWell(
                            child: Container(
                              alignment: Alignment.center,
                              height: 50,
                              child: Text(
                                "下一章",
                                maxLines: 1,
                                style: TextStyle(color: Colors.blue),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: () {
                              _bookTag.cur =
                                  (_bookTag.cur + 1) <= chapters.length - 1
                                      ? (_bookTag.cur + 1)
                                      : chapters.length - 1;
                              _bookTag.index = 0;
                              loadChapter(1);
                            },
                          ),
                        ],
                      ),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          InkWell(
                            child: Container(
                              alignment: Alignment.center,
                              height: 50,
                              child: Text(
                                "目录",
                                maxLines: 1,
                                style: TextStyle(color: Colors.blue),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _globalKey.currentState.openDrawer();
                            },
                          ),
                          InkWell(
                            child: Container(
                              alignment: Alignment.center,
                              height: 50,
                              child: Text(
                                "缓存",
                                maxLines: 1,
                                style: TextStyle(color: Colors.blue),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext bc) {
                                    return new Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          new Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: <Widget>[
                                              InkWell(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  height: 50,
                                                  child: Text(
                                                    "从当前章节缓存",
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        color: Colors.blue),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                onTap: () async {
                                                  for (var i = _bookTag.cur;
                                                      i < chapters.length;
                                                      i++) {
                                                    chapters[i].hasContent = 2;
                                                    justDown(chapters[i].id);
                                                  }
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              InkWell(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  height: 50,
                                                  child: Text(
                                                    "全本缓存",
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        color: Colors.blue),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                onTap: () async {
                                                  for (var i = 0;
                                                      i < chapters.length;
                                                      i++) {
                                                    chapters[i].hasContent = 2;
                                                    justDown(chapters[i].id);
                                                  }
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          ),
                                        ]);
                                  });
                            },
                          ),
                          InkWell(
                            child: Container(
                              alignment: Alignment.center,
                              height: 50,
                              child: Text(
                                "设置",
                                maxLines: 1,
                                style: TextStyle(color: Colors.blue),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: () {},
                          ),
                        ],
                      )
                    ],
                  );
                },
              );
            });
      } else {
        var temp = _bookTag.index + 1;
        if (temp < contents.length) {
          _bookTag.index = temp;
//          saveRecord(_bookTag.index);
        } else {
          int temp = _bookTag.cur + 1;
          if (temp == chapters.length) {
            Toast.show('已经是最后一页');
          } else {
            _bookTag.cur += 1;
            _bookTag.index = 0;
            loadChapter(1);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/read_bg.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: new Scaffold(
        backgroundColor: Colors.transparent,
        key: _globalKey,
        drawer: new Drawer(
          child: new ChapterView(
              chapters, _bookInfo.Id.toString(), _bookTag.cur, _bookInfo.Name),
        ),
        appBar: PreferredSize(
            child: AppBar(
                automaticallyImplyLeading: false,
                elevation: 0,
                backgroundColor: Colors.transparent,
                title: new Text(
                  chapters.isEmpty ? '' : chapters[_bookTag.cur].name,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                )),
            preferredSize: Size.fromHeight(30)),
        body: SafeArea(
          top: true,
          child: new GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (TapDownDetails details) {
              changePage(context, details);
            },
            child: new GestureDetector(
              child: new Container(
//                color: Color(0xFFFFEECC),
                //让容器占满全屏
                height: double.infinity,
                width: double.infinity,
                padding: EdgeInsets.all(15),
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                        text: contents[_bookTag.index],
                        style: TextStyle(fontSize: 20))
                  ]),
                  textAlign: TextAlign.justify,
                ),
              ),

              /*横向拖动的结束状态*/
              onHorizontalDragEnd: (endDetails) {
                if (endDetails.velocity.pixelsPerSecond.dx < 0) {
                  var temp = _bookTag.index + 1;
                  if (temp < contents.length) {
                    setState(() {
                      _bookTag.index = temp;
                    });
//          saveRecord(_bookTag.index);
                  } else {
                    _bookTag.cur = (_bookTag.cur + 1) <= chapters.length - 1
                        ? (_bookTag.cur + 1)
                        : chapters.length - 1;
                    _bookTag.index = 0;
                    loadChapter(1);
                  }
                } else {
                  var temp = _bookTag.index - 1;
                  if (temp >= 0) {
                    setState(() {
                      _bookTag.index = temp;
                    });
                  } else {
                    _bookTag.cur -= 1;
                    loadChapter(0);
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class ChapterView extends StatefulWidget {
  List<Chapter> chapters = [];
  String bookId;
  int cur;
  String bookName;

  ChapterView(this.chapters, this.bookId, this.cur, this.bookName);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new ChapterViewItem(bookId, cur, chapters, bookName);
  }
}

class ChapterViewItem extends State<ChapterView> {
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
  ChapterViewItem(this.bookId, this.cur, this.chapters, this.bookName);

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
        var id = chapters[index].id;
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

    return new Scaffold(
      appBar: AppBar(
        title: new Text(bookName,style: TextStyle(color: Colors.black,fontSize: 16.0),),
        centerTitle: true,
        brightness: Brightness.dark,
        backgroundColor: Colors.white70,
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
