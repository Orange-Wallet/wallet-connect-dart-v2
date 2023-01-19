// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProposalBaseRequiredNamespaceAdapter
    extends TypeAdapter<ProposalBaseRequiredNamespace> {
  @override
  final int typeId = 10;

  @override
  ProposalBaseRequiredNamespace read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProposalBaseRequiredNamespace(
      chains: (fields[0] as List).cast<String>(),
      methods: (fields[1] as List).cast<String>(),
      events: (fields[2] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProposalBaseRequiredNamespace obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.chains)
      ..writeByte(1)
      ..write(obj.methods)
      ..writeByte(2)
      ..write(obj.events);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProposalBaseRequiredNamespaceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProposalRequiredNamespaceAdapter
    extends TypeAdapter<ProposalRequiredNamespace> {
  @override
  final int typeId = 11;

  @override
  ProposalRequiredNamespace read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProposalRequiredNamespace(
      chains: (fields[0] as List).cast<String>(),
      methods: (fields[1] as List).cast<String>(),
      events: (fields[2] as List).cast<String>(),
      extension: (fields[3] as List?)?.cast<ProposalBaseRequiredNamespace>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProposalRequiredNamespace obj) {
    writer
      ..writeByte(4)
      ..writeByte(3)
      ..write(obj.extension)
      ..writeByte(0)
      ..write(obj.chains)
      ..writeByte(1)
      ..write(obj.methods)
      ..writeByte(2)
      ..write(obj.events);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProposalRequiredNamespaceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProposalProposerAdapter extends TypeAdapter<ProposalProposer> {
  @override
  final int typeId = 12;

  @override
  ProposalProposer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProposalProposer(
      publicKey: fields[0] as String,
      metadata: fields[1] as AppMetadata,
    );
  }

  @override
  void write(BinaryWriter writer, ProposalProposer obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.publicKey)
      ..writeByte(1)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProposalProposerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProposalRequestStructAdapter extends TypeAdapter<ProposalRequestStruct> {
  @override
  final int typeId = 14;

  @override
  ProposalRequestStruct read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProposalRequestStruct(
      relays: (fields[0] as List).cast<RelayerProtocolOptions>(),
      proposer: fields[1] as ProposalProposer,
      requiredNamespaces:
          (fields[2] as Map).cast<String, ProposalRequiredNamespace>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProposalRequestStruct obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.relays)
      ..writeByte(1)
      ..write(obj.proposer)
      ..writeByte(2)
      ..write(obj.requiredNamespaces);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProposalRequestStructAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProposalStructAdapter extends TypeAdapter<ProposalStruct> {
  @override
  final int typeId = 5;

  @override
  ProposalStruct read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProposalStruct(
      id: fields[3] as int,
      expiry: fields[4] as int,
      relays: (fields[0] as List).cast<RelayerProtocolOptions>(),
      proposer: fields[1] as ProposalProposer,
      requiredNamespaces:
          (fields[2] as Map).cast<String, ProposalRequiredNamespace>(),
      pairingTopic: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProposalStruct obj) {
    writer
      ..writeByte(6)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.expiry)
      ..writeByte(5)
      ..write(obj.pairingTopic)
      ..writeByte(0)
      ..write(obj.relays)
      ..writeByte(1)
      ..write(obj.proposer)
      ..writeByte(2)
      ..write(obj.requiredNamespaces);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProposalStructAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProposalBaseRequiredNamespace _$ProposalBaseRequiredNamespaceFromJson(
        Map<String, dynamic> json) =>
    ProposalBaseRequiredNamespace(
      chains:
          (json['chains'] as List<dynamic>).map((e) => e as String).toList(),
      methods:
          (json['methods'] as List<dynamic>).map((e) => e as String).toList(),
      events:
          (json['events'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ProposalBaseRequiredNamespaceToJson(
        ProposalBaseRequiredNamespace instance) =>
    <String, dynamic>{
      'chains': instance.chains,
      'methods': instance.methods,
      'events': instance.events,
    };

ProposalRequiredNamespace _$ProposalRequiredNamespaceFromJson(
        Map<String, dynamic> json) =>
    ProposalRequiredNamespace(
      chains:
          (json['chains'] as List<dynamic>).map((e) => e as String).toList(),
      methods:
          (json['methods'] as List<dynamic>).map((e) => e as String).toList(),
      events:
          (json['events'] as List<dynamic>).map((e) => e as String).toList(),
      extension: (json['extension'] as List<dynamic>?)
          ?.map((e) =>
              ProposalBaseRequiredNamespace.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProposalRequiredNamespaceToJson(
    ProposalRequiredNamespace instance) {
  final val = <String, dynamic>{
    'chains': instance.chains,
    'methods': instance.methods,
    'events': instance.events,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull(
      'extension', instance.extension?.map((e) => e.toJson()).toList());
  return val;
}

ProposalProposer _$ProposalProposerFromJson(Map<String, dynamic> json) =>
    ProposalProposer(
      publicKey: json['publicKey'] as String,
      metadata: AppMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProposalProposerToJson(ProposalProposer instance) =>
    <String, dynamic>{
      'publicKey': instance.publicKey,
      'metadata': instance.metadata.toJson(),
    };

ProposalRequestStruct _$ProposalRequestStructFromJson(
        Map<String, dynamic> json) =>
    ProposalRequestStruct(
      relays: (json['relays'] as List<dynamic>)
          .map(
              (e) => RelayerProtocolOptions.fromJson(e as Map<String, dynamic>))
          .toList(),
      proposer:
          ProposalProposer.fromJson(json['proposer'] as Map<String, dynamic>),
      requiredNamespaces:
          (json['requiredNamespaces'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, ProposalRequiredNamespace.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$ProposalRequestStructToJson(
        ProposalRequestStruct instance) =>
    <String, dynamic>{
      'relays': instance.relays.map((e) => e.toJson()).toList(),
      'proposer': instance.proposer.toJson(),
      'requiredNamespaces':
          instance.requiredNamespaces.map((k, e) => MapEntry(k, e.toJson())),
    };

ProposalStruct _$ProposalStructFromJson(Map<String, dynamic> json) =>
    ProposalStruct(
      id: json['id'] as int,
      expiry: json['expiry'] as int,
      relays: (json['relays'] as List<dynamic>)
          .map(
              (e) => RelayerProtocolOptions.fromJson(e as Map<String, dynamic>))
          .toList(),
      proposer:
          ProposalProposer.fromJson(json['proposer'] as Map<String, dynamic>),
      requiredNamespaces:
          (json['requiredNamespaces'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, ProposalRequiredNamespace.fromJson(e as Map<String, dynamic>)),
      ),
      pairingTopic: json['pairingTopic'] as String?,
    );

Map<String, dynamic> _$ProposalStructToJson(ProposalStruct instance) {
  final val = <String, dynamic>{
    'relays': instance.relays.map((e) => e.toJson()).toList(),
    'proposer': instance.proposer.toJson(),
    'requiredNamespaces':
        instance.requiredNamespaces.map((k, e) => MapEntry(k, e.toJson())),
    'id': instance.id,
    'expiry': instance.expiry,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('pairingTopic', instance.pairingTopic);
  return val;
}
