import 'dart:convert';

import 'package:PureBook/common/common.dart';
import 'package:PureBook/common/util.dart';
import 'package:PureBook/entity/Chapter.dart';
import 'package:PureBook/entity/ChapterList.dart';

import 'package:dio/dio.dart';

class BookAction {
  loadChapters(bookId) async {
    var url = Common.chaptersUrl + bookId.toString() + '/';
    Response response = await Util(null).http().get(url);

    String data = response.data;
    String replace = data.replaceAll('},]', '}]');
    var jsonDecode3 = jsonDecode(replace)['data'];
    List jsonDecode2 = jsonDecode3['list'];
    List<Chapter> temp = [];
    var list = jsonDecode2.map((m) => ChapterList.fromJson(m)).toList();
    //第一次加载章节
    for (var i = 0; i < list.length; i++) {
      //目录名hasContent=0
      temp.add(new Chapter(0, 0, list[i].name));
      var list2 = list[i].list;
      for (var j = 0; j < list2.length; j++) {
        temp.add(new Chapter(1, list2[j].id, list2[j].name));
      }
    }
    return temp;
  }
}
