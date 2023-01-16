// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpirerExpiration _$ExpirerExpirationFromJson(Map<String, dynamic> json) =>
    ExpirerExpiration(
      target: json['target'] as String,
      expiry: json['expiry'] as int,
    );

Map<String, dynamic> _$ExpirerExpirationToJson(ExpirerExpiration instance) =>
    <String, dynamic>{
      'target': instance.target,
      'expiry': instance.expiry,
    };

ExpirerEvent _$ExpirerEventFromJson(Map<String, dynamic> json) => ExpirerEvent(
      target: json['target'] as String,
      expiration: ExpirerExpiration.fromJson(
          json['expiration'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ExpirerEventToJson(ExpirerEvent instance) =>
    <String, dynamic>{
      'target': instance.target,
      'expiration': instance.expiration.toJson(),
    };
