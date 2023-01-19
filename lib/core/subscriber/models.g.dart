// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubscriberActiveAdapter extends TypeAdapter<SubscriberActive> {
  @override
  final int typeId = 2;

  @override
  SubscriberActive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubscriberActive(
      id: fields[0] as String,
      relay: fields[1] as RelayerProtocolOptions,
      topic: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SubscriberActive obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.relay)
      ..writeByte(2)
      ..write(obj.topic);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriberActiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
      'id': instance.id,
      'relay': instance.relay.toJson(),
      'topic': instance.topic,
    };
