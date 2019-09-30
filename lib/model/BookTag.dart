import 'package:PureBook/model/Chapter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'BookTag.g.dart';

@JsonSerializable()
class BookTag {
  List<Map<String, int>> pageOffsets;

  String content;

  String stringAtPageIndex(int index) {
    var offset = pageOffsets[index];
    return this.content.substring(offset['start'], offset['end']);
  }

  int get pageCount {
    return pageOffsets.length;
  }

  int pageLen = 280;
  double fontSize = 22.0;
  String name = "";
  int first;
  int last;
  int cur;
  int index;
  List<Chapter> chapters;
  List<String> contents;

  factory BookTag.fromJson(Map<String, dynamic> json) =>
      _$BookTagFromJson(json);

  Map<String, dynamic> toJson() => _$BookTagToJson(this);

  BookTag(this.first, this.last, this.cur, this.index, this.chapters, this.name,
      this.contents);

  @override
  String toString() {
    return 'BookTag{pageLen: $pageLen, fontSize: $fontSize, name: $name, first: $first, last: $last, cur: $cur, index: $index, chapters: $chapters}';
  }
}
