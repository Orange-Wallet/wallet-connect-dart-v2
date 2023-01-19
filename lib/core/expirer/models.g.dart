// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpirerExpirationAdapter extends TypeAdapter<ExpirerExpiration> {
  @override
  final int typeId = 1;

  @override
  ExpirerExpiration read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpirerExpiration(
      target: fields[0] as String,
      expiry: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ExpirerExpiration obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.target)
      ..writeByte(1)
      ..write(obj.expiry);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpirerExpirationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
