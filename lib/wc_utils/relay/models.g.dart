// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RelayJsonRpcSubscribeParams _$RelayJsonRpcSubscribeParamsFromJson(
        Map<String, dynamic> json) =>
    RelayJsonRpcSubscribeParams(
      topic: json['topic'] as String,
    );

Map<String, dynamic> _$RelayJsonRpcSubscribeParamsToJson(
        RelayJsonRpcSubscribeParams instance) =>
    <String, dynamic>{
      'topic': instance.topic,
    };

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
    RelayJsonRpcPublishParams instance) {
  final val = <String, dynamic>{
    'topic': instance.topic,
    'message': instance.message,
    'ttl': instance.ttl,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('prompt', instance.prompt);
  writeNotNull('tag', instance.tag);
  return val;
}

RelayJsonRpcSubscriptionData _$RelayJsonRpcSubscriptionDataFromJson(
        Map<String, dynamic> json) =>
    RelayJsonRpcSubscriptionData(
      topic: json['topic'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$RelayJsonRpcSubscriptionDataToJson(
        RelayJsonRpcSubscriptionData instance) =>
    <String, dynamic>{
      'topic': instance.topic,
      'message': instance.message,
    };

RelayJsonRpcSubscriptionParams _$RelayJsonRpcSubscriptionParamsFromJson(
        Map<String, dynamic> json) =>
    RelayJsonRpcSubscriptionParams(
      id: json['id'] as String,
      data: RelayJsonRpcSubscriptionData.fromJson(
          json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RelayJsonRpcSubscriptionParamsToJson(
        RelayJsonRpcSubscriptionParams instance) =>
    <String, dynamic>{
      'id': instance.id,
      'data': instance.data.toJson(),
    };

RelayJsonRpcUnsubscribeParams _$RelayJsonRpcUnsubscribeParamsFromJson(
        Map<String, dynamic> json) =>
    RelayJsonRpcUnsubscribeParams(
      id: json['id'] as String,
      topic: json['topic'] as String,
    );

Map<String, dynamic> _$RelayJsonRpcUnsubscribeParamsToJson(
        RelayJsonRpcUnsubscribeParams instance) =>
    <String, dynamic>{
      'id': instance.id,
      'topic': instance.topic,
    };
