import 'dart:io';

import 'package:PureBook/entity/Book.dart';
import 'package:PureBook/model/ThemeModel.dart';
import 'package:PureBook/service/TelAndSmsService.dart';
import 'package:PureBook/store/Store.dart';
import 'package:PureBook/view/BookShelf.dart';
import 'package:PureBook/view/PersonCenter.dart';
import 'package:PureBook/view/TopBook.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import 'event/event.dart';
MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  keywords: <String>['games', 'pubg'],
  contentUrl: 'https://flutter.cn',
  birthday: DateTime.now(),
  childDirected: false,
  designedForFamilies: false,
  gender: MobileAdGender.male, // or MobileAdGender.female, MobileAdGender.unknown
  testDevices: <String>[], // Android emulators are considered test devices
);

BannerAd myBanner = BannerAd(
  adUnitId: 'ca-app-pub-6006602100377888/8012817232',
  size: AdSize.smartBanner,
  targetingInfo: targetingInfo,
  listener: (MobileAdEvent event) {
    print("BannerAd event is $event");
  },
);
//ca-app-pub-6006602100377888~3769076624
//ca-app-pub-6006602100377888/8012817232
List<Book> books = [];
GetIt locator = GetIt.instance;
void main() async {
  await SpUtil.getInstance();
  await DirectoryUtil.getInstance();

  locator.registerSingleton(TelAndSmsService());
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
    myBanner
    // typically this happens well before the ad is shown
      ..load()
      ..show(
        // Positions the banner ad 60 pixels from the bottom of the screen
        anchorOffset: 60.0,
        // Positions the banner ad 10 pixels from the center of the screen to the right
        horizontalCenterOffset: 10.0,
        // Banner Position
        anchorType: AnchorType.bottom,
      );
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
