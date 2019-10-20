// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Book _$BookFromJson(Map<String, dynamic> json) {
  return Book(
      json['ChapterId'] as int,
      json['ChapterName'] as String,
      json['NewChapterCount'] as int,
      json['Id'] as int,
      json['Name'] as String,
      json['Author'] as String,
      json['Img'] as String,
      json['LastChapterId'] as int,
      json['LastChapter'] as String,
      json['UpdateTime'] as String);
}

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
      'ChapterId': instance.ChapterId,
      'ChapterName': instance.ChapterName,
      'NewChapterCount': instance.NewChapterCount,
      'Id': instance.Id,
      'Name': instance.Name,
      'Author': instance.Author,
      'Img': instance.Img,
      'LastChapterId': instance.LastChapterId,
      'LastChapter': instance.LastChapter,
      'UpdateTime': instance.UpdateTime
    };
