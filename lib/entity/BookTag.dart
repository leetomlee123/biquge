import 'package:PureBook/entity/Chapter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'BookTag.g.dart';

@JsonSerializable()
class BookTag {
  List<int> pageOffsets = [];

  String content;

  String stringAtPageIndex(int index) {

    return this.content.substring(index-1==-1?0:pageOffsets[index-1], pageOffsets[index]);
  }

  int get pageCount {
    return pageOffsets.length;
  }



  String name = "";
  int cur;
  int index;
  List<Chapter> chapters;

  factory BookTag.fromJson(Map<String, dynamic> json) =>
      _$BookTagFromJson(json);

  Map<String, dynamic> toJson() => _$BookTagToJson(this);

  BookTag(this.cur, this.index, this.chapters, this.name);

  @override
  String toString() {
    return 'BookTag{pageOffsets: $pageOffsets, content: $content, name: $name, cur: $cur, index: $index, chapters: $chapters}';
  }

}
