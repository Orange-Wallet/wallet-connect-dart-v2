// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IridiumJWTHeader _$IridiumJWTHeaderFromJson(Map<String, dynamic> json) =>
    IridiumJWTHeader(
      alg: json['alg'] as String? ?? "EdDSA",
      typ: json['typ'] as String? ?? "JWT",
    );

Map<String, dynamic> _$IridiumJWTHeaderToJson(IridiumJWTHeader instance) =>
    <String, dynamic>{
      'alg': instance.alg,
      'typ': instance.typ,
    };

IridiumJWTPayload _$IridiumJWTPayloadFromJson(Map<String, dynamic> json) =>
    IridiumJWTPayload(
      iss: json['iss'] as String,
      sub: json['sub'] as String,
      aud: json['aud'] as String,
      iat: json['iat'] as int,
      exp: json['exp'] as int,
    );

Map<String, dynamic> _$IridiumJWTPayloadToJson(IridiumJWTPayload instance) =>
    <String, dynamic>{
      'iss': instance.iss,
      'sub': instance.sub,
      'aud': instance.aud,
      'iat': instance.iat,
      'exp': instance.exp,
    };
