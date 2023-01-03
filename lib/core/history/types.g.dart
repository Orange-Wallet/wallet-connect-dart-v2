// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JsonRpcRecord _$JsonRpcRecordFromJson(Map<String, dynamic> json) =>
    JsonRpcRecord(
      id: json['id'] as int,
      topic: json['topic'] as String,
      request: json['request'] as Map<String, dynamic>,
      chainId: json['chainId'] as String?,
      response: json['response'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$JsonRpcRecordToJson(JsonRpcRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'topic': instance.topic,
      'request': instance.request,
      'chainId': instance.chainId,
      'response': instance.response,
    };
