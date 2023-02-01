// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingStruct _$PairingStructFromJson(Map<String, dynamic> json) =>
    PairingStruct(
      topic: json['topic'] as String,
      expiry: json['expiry'] as int,
      relay: RelayerProtocolOptions.fromJson(
          json['relay'] as Map<String, dynamic>),
      active: json['active'] as bool,
      peerMetadata: json['peerMetadata'] == null
          ? null
          : AppMetadata.fromJson(json['peerMetadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PairingStructToJson(PairingStruct instance) {
  final val = <String, dynamic>{
    'topic': instance.topic,
    'expiry': instance.expiry,
    'relay': instance.relay.toJson(),
    'active': instance.active,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('peerMetadata', instance.peerMetadata?.toJson());
  return val;
}
