// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RelayerProtocolOptions _$RelayerProtocolOptionsFromJson(
        Map<String, dynamic> json) =>
    RelayerProtocolOptions(
      protocol: json['protocol'] as String,
      data: json['data'] as String?,
    );

Map<String, dynamic> _$RelayerProtocolOptionsToJson(
    RelayerProtocolOptions instance) {
  final val = <String, dynamic>{
    'protocol': instance.protocol,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('data', instance.data);
  return val;
}

RelayerSubscribeOptions _$RelayerSubscribeOptionsFromJson(
        Map<String, dynamic> json) =>
    RelayerSubscribeOptions(
      relay: RelayerProtocolOptions.fromJson(
          json['relay'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RelayerSubscribeOptionsToJson(
        RelayerSubscribeOptions instance) =>
    <String, dynamic>{
      'relay': instance.relay.toJson(),
    };

RelayerUnsubscribeOptions _$RelayerUnsubscribeOptionsFromJson(
        Map<String, dynamic> json) =>
    RelayerUnsubscribeOptions(
      id: json['id'] as String?,
      relay: RelayerProtocolOptions.fromJson(
          json['relay'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RelayerUnsubscribeOptionsToJson(
    RelayerUnsubscribeOptions instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  val['relay'] = instance.relay.toJson();
  return val;
}

RelayerMessageEvent _$RelayerMessageEventFromJson(Map<String, dynamic> json) =>
    RelayerMessageEvent(
      topic: json['topic'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$RelayerMessageEventToJson(
        RelayerMessageEvent instance) =>
    <String, dynamic>{
      'topic': instance.topic,
      'message': instance.message,
    };
