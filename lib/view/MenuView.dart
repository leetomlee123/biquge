import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

class MenuView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MenuState();
  }
}

class _MenuState extends State<MenuView> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Material(child: Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(top: ScreenUtil.getStatusBarH(context) - 1,bottom: 1),
      child: Column(
        children: <Widget>[
         Expanded(child:  Container(),),
          Row(

            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 1,
              ),
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
//                  _bookTag.index = 0;
//                  _bookTag.cur -= 1;
//                  loadChapter(0);
                },
              ),
              Slider(
                value: 0,
//                value: value,
//                max: (chapters.length - 1).toDouble(),
                min: 0.0,
                onChanged: (newValue) {
//                  int temp = newValue.round();
//                  _bookTag.cur = temp;
//                  loadChapter(1);
//
//                  state(() {
//                    ///为了区分把setState改个名字
//                    value = _bookTag.cur.toDouble();
//                  });
                },
//                label: '${chapters[_bookTag.cur].name} ',
//                divisions: chapters.length,
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
//                  _bookTag.cur =
//                  (_bookTag.cur + 1) <= chapters.length - 1
//                      ? (_bookTag.cur + 1)
//                      : chapters.length - 1;
//                  _bookTag.index = 0;
//                  loadChapter(1);
                },
              ),
              SizedBox(
                width: 1,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 1,
              ),
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
//                  Navigator.pop(context);
//                  _globalKey.currentState.openDrawer();
                },
              ),
              IconButton(
                icon: ImageIcon(
                  AssetImage("images/font_jia.png"),
                  color: Colors.blue,
                ),
                onPressed: () async {
//                  state(() {
//                    ///为了区分把setState改个名字
//                    fontSize += 1;
//                  });
//                  setState(() {
//                    _bookTag.index = 0;
//                    _bookTag.pageOffsets =
//                        ReaderPageAgent.getPageOffsets(
//                            _bookTag.content,
//                            contentH,
//                            contentW,
//                            fontSize);
//                  });
//                              changeCachePages();
                },
              ),
              Container(
                alignment: Alignment.center,
                height: 50,
                child: Text(
//                  fontSize.toString(),
                  '',
                  style: TextStyle(
                      color: Colors.blueAccent, fontSize: 17),
                ),
              ),
              IconButton(
                icon: ImageIcon(
                  AssetImage("images/font_jian.png"),
                  color: Colors.blue,
                ),
                onPressed: () async {
//                  state(() {
//                    ///为了区分把setState改个名字
//                    fontSize -= 1;
//                    setState(() {
//                      _bookTag.index = 0;
//                      _bookTag.pageOffsets =
//                          ReaderPageAgent.getPageOffsets(
//                              _bookTag.content,
//                              contentH,
//                              contentW,
//                              fontSize);
//                    });
//                  });
//                              changeCachePages();
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
                        return Column(
                            mainAxisSize: MainAxisSize.min,
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
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                onTap: () async {
//                                  justDown(_bookTag.cur,
//                                      chapters.length);
//
//                                  Navigator.pop(context);
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
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                onTap: () async {
//                                  justDown(0, chapters.length);
//                                  Navigator.pop(context);
                                },
                              ),
                            ]);
                      });
                },
              ),
              SizedBox(
                width: 1,
              ),
            ],
          ),
        ],
      ),
    ),);
  }
}
