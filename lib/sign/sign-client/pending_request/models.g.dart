// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingRequestStructAdapter extends TypeAdapter<PendingRequestStruct> {
  @override
  final int typeId = 4;

  @override
  PendingRequestStruct read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingRequestStruct(
      fields[0] as String,
      fields[1] as int,
      fields[2] as RequestSessionRequest,
    );
  }

  @override
  void write(BinaryWriter writer, PendingRequestStruct obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.topic)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.params);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingRequestStructAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PendingRequestStruct _$PendingRequestStructFromJson(
        Map<String, dynamic> json) =>
    PendingRequestStruct(
      json['topic'] as String,
      json['id'] as int,
      RequestSessionRequest.fromJson(json['params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PendingRequestStructToJson(
        PendingRequestStruct instance) =>
    <String, dynamic>{
      'topic': instance.topic,
      'id': instance.id,
      'params': instance.params.toJson(),
    };
