// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

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

Map<String, dynamic> _$JsonRpcRecordToJson(JsonRpcRecord instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'topic': instance.topic,
    'request': instance.request,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('chainId', instance.chainId);
  writeNotNull('response', instance.response);
  return val;
}
