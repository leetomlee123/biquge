import 'package:flutter/material.dart';

class ReaderPageAgent {
  TextPainter _painter;
  String content;
  int _totalOffset = 0;
  List<String> contents = [];
  Size size;

  ReaderPageAgent(this.content,
      this.size); //  static List<String> getPageOffsets(String content, double fontSize, height) {
//    print(content);
//    height = 600.0;
//    var width = Screen.width - 15 - 15;
//    String tempStr = content;
//    List<String> contents = [];
//    int last = 0;
//    while (true) {
//      TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
//      textPainter.text =
//          TextSpan(text: tempStr, style: TextStyle(fontSize: fontSize));
//      textPainter.layout(maxWidth: width);
//
//      var end = textPainter.getPositionForOffset(Offset(width, height)).offset;
//      if (end == 0) {
//        break;
//      }
//      tempStr = tempStr.substring(end, tempStr.length);
//      var substring = content.substring(last, last + end);
//      if (substring.startsWith('\n')) {
//        substring = substring.substring(1);
//      }
//      contents.add(substring);
//      last += end;
//    }
//
//    return contents;
//  }
  TextPainter _textPainter(String content) {
    return TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: content ?? '',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ));
  }

  _caculatePages(content) {
    content = content.toString().trim();
    if(content.toString().startsWith('\n')){
      content=content.toString().substring(1);
    }
    // getPositionForOffset可以拿到在屏幕内的字符串偏移量,不超过绘制size 文字的最大偏移量,这也就是每一页的字数
    TextPosition position =
        this._painter.getPositionForOffset(Offset(size.width, size.height));
    String string = content;
    // 这里递归进行页数计算
    while (_painter.size.height > size.height) {
      print('item ${_painter.size.height}');

      // _totalOffset是每次递归后的偏移量之和
      _totalOffset += position.offset;
      // position.offset 就是每一页的字数,通过这个offset进行字符串截取
      // remainString 表示截取后剩下的字符串,来计算page
      String remainString = string.substring(position.offset);
      // 得到每一页的内容
      String pageString = string.substring(0, position.offset);
      print(pageString);
      // 根据页码保存每页的内容
      contents.add(pageString);
//      // 对剩下的文字,重新布局,但不需要绘制,重新计算剩下内容真实布局高度
      this._painter = _textPainter(remainString);
      this._painter.layout(maxWidth: size.width, minWidth: 0);
      // 递归计算页面数量
      _caculatePages(remainString);
    }
  }

  getPages() {
    // 通过content创建一个TextPainter对象
    _painter = _textPainter(this.content);
    // 通过layout方法进行布局,但此时并未绘制
    _painter.layout(maxWidth: size.width, minWidth: 0);

    // 这时布局之后,可以拿到绘制内容的实际高度
    double paintHeight = _painter.size.height;
    print('all $paintHeight');
    // 拿到章节内容总字数
    int contentLength = this.content.length;

    // 关键方法,计算超出区域的页数
    _caculatePages(content);

    // 最后未能铺满绘制size的内容
    if (contentLength - _totalOffset > 0) {
      String lastContent = this.content.substring(_totalOffset);
      // 排除末尾的一些特殊字符,暂时就换行或空格
      if (lastContent == '\n' || lastContent == ' ') {
        return;
      }
      contents.add(lastContent);
    }
  }
}
