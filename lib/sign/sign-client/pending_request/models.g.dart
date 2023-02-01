// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PendingRequestStruct _$PendingRequestStructFromJson(
        Map<String, dynamic> json) =>
    PendingRequestStruct(
      json['topic'] as String,
      json['id'] as int,
      RequestSessionRequest.fromJson(json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PendingRequestStructToJson(
        PendingRequestStruct instance) =>
    <String, dynamic>{
      'topic': instance.topic,
      'id': instance.id,
      'params': instance.params.toJson(),
    };
