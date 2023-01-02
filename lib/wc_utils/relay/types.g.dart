// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RelayJsonRpcPublishParams _$RelayJsonRpcPublishParamsFromJson(
        Map<String, dynamic> json) =>
    RelayJsonRpcPublishParams(
      topic: json['topic'] as String,
      message: json['message'] as String,
      ttl: json['ttl'] as int,
      prompt: json['prompt'] as bool?,
      tag: json['tag'] as int?,
    );

Map<String, dynamic> _$RelayJsonRpcPublishParamsToJson(
        RelayJsonRpcPublishParams instance) =>
    <String, dynamic>{
      'topic': instance.topic,
      'message': instance.message,
      'ttl': instance.ttl,
      'prompt': instance.prompt,
      'tag': instance.tag,
    };
