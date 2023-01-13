// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriberActive _$SubscriberActiveFromJson(Map<String, dynamic> json) =>
    SubscriberActive(
      id: json['id'] as String,
      relay: RelayerProtocolOptions.fromJson(
          json['relay'] as Map<String, dynamic>),
      topic: json['topic'] as String,
    );

Map<String, dynamic> _$SubscriberActiveToJson(SubscriberActive instance) =>
    <String, dynamic>{
      'relay': instance.relay.toJson(),
      'topic': instance.topic,
      'id': instance.id,
    };
