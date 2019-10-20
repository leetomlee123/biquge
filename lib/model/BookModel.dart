import 'dart:convert';

import 'package:PureBook/common/common.dart';
import 'package:PureBook/common/util.dart';
import 'package:PureBook/entity/BookInfo.dart';
import 'package:PureBook/entity/BookTag.dart';
import 'package:PureBook/entity/Chapter.dart';
import 'package:PureBook/entity/ChapterList.dart';
import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

class BookModel with ChangeNotifier {
  BookTag _bookTag;

  BookTag get bookTag => _bookTag;

  set bookTag(BookTag value) {
    _bookTag = value;
  }

  void init(BookInfo _bookInfo, BuildContext context) {
    getChapters(_bookInfo, context);
  }

  getChapters(BookInfo _bookInfo, BuildContext context) async {
    var url = Common.chaptersUrl + _bookInfo.Id.toString() + '/';
    var _context = null;
    if (!SpUtil.haveKey(_bookInfo.Id.toString())) {
      _context = context;
    }
    Response response = await Util(_context).http().get(url);

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
    temp.setAll(0, _bookTag.chapters);

    _bookTag.chapters = temp;
    _bookTag.chapters = temp;
    SpUtil.putString(_bookInfo.Id.toString(), jsonEncode(_bookTag));
    //书的最后一章
    if (_bookInfo.CId == -1) {
      _bookTag.cur = _bookTag.chapters.length - 1;
    }
  }
}
