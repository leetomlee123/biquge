import 'package:json_annotation/json_annotation.dart';
part 'Book.g.dart';
@JsonSerializable()
class Book {

  int ChapterId;
  String ChapterName;
  int NewChapterCount;
  int Id;
  String Name;
  String Author;
  String Img;
  int LastChapterId;
  String LastChapter;
  String UpdateTime;

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);

  Map<String, dynamic> toJson() => _$BookToJson(this);

  Book(
      this.ChapterId,
      this.ChapterName,
      this.NewChapterCount,
      this.Id,
      this.Name,
      this.Author,
      this.Img,
      this.LastChapterId,
      this.LastChapter,
      this.UpdateTime);

  @override
  String toString() {
    return 'Book{ChapterId: $ChapterId, ChapterName: $ChapterName, NewChapterCount: $NewChapterCount, Id: $Id, Name: $Name, Author: $Author, Img: $Img, LastChapterId: $LastChapterId, LastChapter: $LastChapter, UpdateTime: $UpdateTime}';
  }
}
