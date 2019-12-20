import 'dart:convert';

import 'package:PureBook/common/common.dart';
import 'package:PureBook/common/util.dart';
import 'package:PureBook/entity/BookInfo.dart';
import 'package:PureBook/entity/TopBook.dart';
import 'package:PureBook/entity/TopResult.dart';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
  Map word2 = {
    0: 'hot',
    1: 'commend',
    2: 'over',
    3: 'collect',
    4: 'new',
    5: 'vote'
  };
  Map word3 = {0: 'week', 1: 'month', 2: 'total'};
  int idx1 = 0;
  int idx2 = 0;
  int idx3 = 0;
  Widget body;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<TopBooks> items = [];
  TopResult topResult;
  int page = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      /// 接口请求
      initUi();
    });
  }

  void _onRefresh() async {
    items = [];
    page = 1;
    getTop();
    if (mounted) {
      setState(() {});
    }
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    page += 1;
    getTop();
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  Widget _buildContent() {
    return CustomScrollView(slivers: <Widget>[
      SliverToBoxAdapter(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                children: getBtnGroup(lv1, idx1, 0, ['男生', '女生']),
              ),
              Wrap(
                children: getBtnGroup(
                    lv2, idx2, 1, ['最热', '推荐', '完结', '收藏', '新书', '评分']),
              ),
              Wrap(children: getBtnGroup(lv3, idx3, 2, ['周榜', ' 月榜', '总榜'])),
            ],
          ),
        ),
      ),
      SliverFixedExtentList(
          delegate: SliverChildBuilderDelegate(_buildListItem,
              childCount: items.length),
          itemExtent: 118.0)
    ]);
  }

  // 列表项
  Widget _buildListItem(BuildContext context, int i) {
    var auth = items[i].Author;
    var cate = items[i].CName;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        verticalDirection: VerticalDirection.up,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                child: ExtendedImage.network(
                  Common.imgPre + items[i].Img,
                  height: 100,
                  width: 80,
                  fit: BoxFit.cover,
                  cache: true,
                ),
              )
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                    child: Row(
                      children: <Widget>[
                        Text(
                          items[i].Name,
                          style: TextStyle(fontSize: 15),
                        ),
                        Expanded(child: Container()),
                        Container(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: Text(
                            items[i].Score.toString(),
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    )),
                Container(
                  padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                  child: new Text('$cate | $auth',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                  child: new Text(items[i].Desc,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  width: 270,
                ),
              ],
            ),
          ),
        ],
      ),
      onTap: () async {
        String url = 'https://shuapi.jiaston.com/info/${items[i].Id}.html';

        Response future = await Util(context).http().get(url);

        var data = jsonDecode(future.data)['data'];
        BookInfo bookInfo = new BookInfo.fromJson(data);
        Navigator.of(context).push(new MaterialPageRoute(
            builder: (BuildContext context) => new BookDetail(bookInfo)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromARGB(1, 245, 245, 245),
        centerTitle: true,
        title: Text(
          '排行榜',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
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
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: _buildContent(),
      ),
    );

    // TODO: implement build
  }

  getBtnGroup(leve, idx, who, List<String> names) {
    List<Widget> btns = [];
    for (var i = 0; i < names.length; i++) {
      btns.add(Padding(
        child: InkWell(
          child: Container(
            child: Center(
              child: Text(
                names[i],
              ),
            ),
            width: 60,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: leve && i == idx ? Colors.grey : Colors.transparent,
            ),
          ),
          onTap: () {
            setState(() {
              switch (who) {
                case 0:
                  {
                    setState(() {
                      idx1 = i;
                      items = [];
                      _refreshController.resetNoData();
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
                      _refreshController.resetNoData();
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
                      _refreshController.resetNoData();
                      page = 1;
                      getTop();
                    });
                  }
                  break;
              }
            });
          },
        ),
        padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
      ));
    }
    return btns;
  }

  getTop() async {
    String url =
        '${Common.domain}/top/${word1[idx1]}/top/${word2[idx2]}/${word3[idx3]}/$page.html';
    Response res = await Util(null).http().get(url);

    topResult = new TopResult.fromJson(jsonDecode(res.data)['data']);

    items.addAll(topResult.BookList);
    if (!topResult.HasNext) {
      _refreshController.loadNoData();
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

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
    var _context = null;
    if (!exist) {
      _context = context;
    }
    Response res = await Util(_context).http().get(url);

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
