// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PendingRequestTypesStruct _$PendingRequestTypesStructFromJson(
        Map<String, dynamic> json) =>
    PendingRequestTypesStruct(
      json['topic'] as String,
      json['id'] as int,
      RpcSessionRequestParams.fromJson(json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PendingRequestTypesStructToJson(
        PendingRequestTypesStruct instance) =>
    <String, dynamic>{
      'topic': instance.topic,
      'id': instance.id,
      'params': instance.params,
    };
