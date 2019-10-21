import 'dart:io';

import 'package:PureBook/entity/Book.dart';
import 'package:PureBook/model/ThemeModel.dart';
import 'package:PureBook/store/Store.dart';
import 'package:PureBook/view/BookShelf.dart';
import 'package:PureBook/view/PersonCenter.dart';
import 'package:PureBook/view/TopBook.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'event/event.dart';

List<Book> books = [];



void main() async {

  await SpUtil.getInstance();
  await DirectoryUtil.getInstance();

  runApp(Store.init(child: MyApp()));
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return MaterialApp(
      title: '清阅揽胜',
      theme: Store.value<AppThemeModel>(context).getThemeData(),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _tabIndex = 0;

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
  ];

  /*
   * 存储的四个页面，和Fragment一样
   */
  var _pages = [
    new BookShelf(),
    new TopBook(),
  ];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: Drawer(
        child: PersonCenter(),
      ),
      key: _scaffoldKey,
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
      bottomNavigationBar: BottomNavigationBar(
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
    eventBus.on<OpenEvent>().listen((OpenEvent openEvent) => openDrawer());
    eventBus
        .on<SyncShelfEvent>()
        .listen((SyncShelfEvent booksEvent) => closeDrawer());
  }

  closeDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  openDrawer() {
    _scaffoldKey.currentState.openDrawer();
  }
}
