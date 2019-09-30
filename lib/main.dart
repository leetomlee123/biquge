import 'package:PureBook/view/BookShelf.dart';
import 'package:PureBook/view/PersonCenter.dart';
import 'package:PureBook/view/Search.dart';
import 'package:PureBook/view/TopBook.dart';
import 'package:PureBook/view/Video.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'event/event.dart';
import 'model/Book.dart';

Widget bodyWidget;
List<Book> books = [];

void main() async {
  await SpUtil.getInstance();

  runApp(MyApp());
  SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.transparent,
  );
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new MaterialApp(
      title: '清阅揽胜',
      theme: ThemeData.light(),
      home: new MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _tabIndex = 0;
  var appBarTitles = {0: "书架", 1: "排行榜",2:'影音揽胜'};
  var _pageController = PageController();
  List<BottomNavigationBarItem> bottoms = [
    BottomNavigationBarItem(
        icon: ImageIcon(
          AssetImage("images/shelf.png"),
        ),
        title: new Text(
          '书架',
        )),
    BottomNavigationBarItem(
        icon: ImageIcon(
          AssetImage("images/rank.png"),
        ),
        title: new Text(
          '排行榜',
        )),
    BottomNavigationBarItem(
        icon: ImageIcon(
          AssetImage("images/video.png"),
        ),
        title: new Text(
          '影音揽胜',
        )),
  ];

  Text getTabTitle(int curIndex) {
    if (curIndex == _tabIndex) {
      return new Text(appBarTitles[curIndex]);
    } else {
      return new Text(appBarTitles[curIndex]);
    }
  }

  /*
   * 存储的四个页面，和Fragment一样
   */
  var _pages = [
    new BookShelf(),
    new TopBook(),
    new Video()
  ];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: new Drawer(
        child: PersonCenter(),
      ),
      key: _scaffoldKey,
      appBar: new AppBar(
        leading: _tabIndex == 0?new IconButton(
          color: Colors.black,
          icon: ImageIcon(
            AssetImage("images/account.png"),
          ),
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
        ):null,
        backgroundColor: Color.fromARGB(1, 245, 245, 245),
        elevation: 0,
        title: new Text(
          appBarTitles[_tabIndex],
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
        centerTitle: true,
        actions: _tabIndex == 0
            ? <Widget>[
                IconButton(
                    icon: Icon(Icons.search),
                    color: Colors.black,
                    tooltip: '搜索小说',
                    onPressed: () {
                      showSearch(
                          context: context, delegate: SearchBarDelegate());
                    }),
                IconButton(
                    icon: Icon(Icons.add),
                    color: Colors.black,
                    tooltip: '添加',
                    onPressed: () {
                      // do nothing
                    }),
              ]
            : [],
      ),
      body: SafeArea(
        child: PageView.builder(
            //要点1
            physics: NeverScrollableScrollPhysics(),
            //禁止页面左右滑动切换
            controller: _pageController,
            onPageChanged: _pageChanged,
            //回调函数
            itemCount: _pages.length,
            itemBuilder: (context, index) => _pages[index]),
      ),
      bottomNavigationBar: new BottomNavigationBar(
        items: bottoms,
        type: BottomNavigationBarType.fixed,
        currentIndex: _tabIndex,
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
      ),
    );
  }

  void _pageChanged(int index) {
    setState(() {
      if (_tabIndex != index) _tabIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    eventBus.on<BooksEvent>().listen((BooksEvent booksEvent) => closeDrawer());
    eventBus
        .on<SyncShelfEvent>()
        .listen((SyncShelfEvent booksEvent) => closeDrawer());
  }

  closeDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }
}
