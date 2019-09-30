import 'package:json_annotation/json_annotation.dart';

import 'BookVotec.dart';
part 'BookInfo.g.dart';
@JsonSerializable()
class BookInfo {
  String Author;
  String BookStatus;
  BookVotec BookVote;
  int CId;
  String CName;
  int Id;
  String Name="";
  String Img;
  String Desc;
  int LastChapterId;
  String LastChapter;
  int FirstChapterId;
  String LastTime;

  factory BookInfo.fromJson(Map<String, dynamic> json) =>
      _$BookInfoFromJson(json);

  Map<String, dynamic> toJson() => _$BookInfoToJson(this);

  BookInfo.id(this.Id,this.Name);

  BookInfo.name(this.CId, this.Name);

  BookInfo(
      this.Author,
      this.BookStatus,
      this.BookVote,
      this.CId,
      this.CName,
      this.Id,
      this.Name,
      this.Img,
      this.Desc,
      this.LastChapterId,
      this.LastChapter,
      this.FirstChapterId,
      this.LastTime);

  @override
  String toString() {
    return 'BookInfo{Author: $Author, BookStatus: $BookStatus, BookVote: $BookVote, CId: $CId, CName: $CName, Id: $Id, Name: $Name, Img: $Img, Desc: $Desc, LastChapterId: $LastChapterId, LastChapter: $LastChapter, FirstChapterId: $FirstChapterId, LastTime: $LastTime}';
  }


}
