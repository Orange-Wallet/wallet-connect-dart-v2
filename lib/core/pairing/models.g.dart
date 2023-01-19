// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PairingStructAdapter extends TypeAdapter<PairingStruct> {
  @override
  final int typeId = 7;

  @override
  PairingStruct read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PairingStruct(
      topic: fields[0] as String,
      expiry: fields[1] as int,
      relay: fields[2] as RelayerProtocolOptions,
      active: fields[3] as bool,
      peerMetadata: fields[4] as AppMetadata?,
    );
  }

  @override
  void write(BinaryWriter writer, PairingStruct obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.topic)
      ..writeByte(1)
      ..write(obj.expiry)
      ..writeByte(2)
      ..write(obj.relay)
      ..writeByte(3)
      ..write(obj.active)
      ..writeByte(4)
      ..write(obj.peerMetadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PairingStructAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
