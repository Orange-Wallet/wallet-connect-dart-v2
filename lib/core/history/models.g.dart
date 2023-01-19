// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JsonRpcRecordAdapter extends TypeAdapter<JsonRpcRecord> {
  @override
  final int typeId = 0;

  @override
  JsonRpcRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JsonRpcRecord(
      id: fields[0] as int,
      topic: fields[1] as String,
      request: (fields[2] as Map).cast<String, dynamic>(),
      chainId: fields[3] as String?,
      response: (fields[4] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, JsonRpcRecord obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.topic)
      ..writeByte(2)
      ..write(obj.request)
      ..writeByte(3)
      ..write(obj.chainId)
      ..writeByte(4)
      ..write(obj.response);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonRpcRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JsonRpcRecord _$JsonRpcRecordFromJson(Map<String, dynamic> json) =>
    JsonRpcRecord(
      id: json['id'] as int,
      topic: json['topic'] as String,
      request: json['request'] as Map<String, dynamic>,
      chainId: json['chainId'] as String?,
      response: json['response'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$JsonRpcRecordToJson(JsonRpcRecord instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'topic': instance.topic,
    'request': instance.request,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('chainId', instance.chainId);
  writeNotNull('response', instance.response);
  return val;
}
