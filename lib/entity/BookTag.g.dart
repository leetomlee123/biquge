// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BookTag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookTag _$BookTagFromJson(Map<String, dynamic> json) {
  return BookTag(
      json['cur'] as int,
      json['index'] as int,
      (json['chapters'] as List)
          ?.map((e) =>
              e == null ? null : Chapter.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      json['name'] as String)
    ..pageOffsets =
        (json['pageOffsets'] as List)?.map((e) => e as int)?.toList()
    ..content = json['content'] as String;
}

Map<String, dynamic> _$BookTagToJson(BookTag instance) => <String, dynamic>{
      'pageOffsets': instance.pageOffsets,
      'content': instance.content,
      'name': instance.name,
      'cur': instance.cur,
      'index': instance.index,
      'chapters': instance.chapters
    };
