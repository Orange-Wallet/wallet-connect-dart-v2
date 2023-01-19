// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionBaseNamespaceAdapter extends TypeAdapter<SessionBaseNamespace> {
  @override
  final int typeId = 8;

  @override
  SessionBaseNamespace read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionBaseNamespace(
      accounts: (fields[0] as List).cast<String>(),
      methods: (fields[1] as List).cast<String>(),
      events: (fields[2] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SessionBaseNamespace obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.accounts)
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
      other is SessionBaseNamespaceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SessionNamespaceAdapter extends TypeAdapter<SessionNamespace> {
  @override
  final int typeId = 9;

  @override
  SessionNamespace read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionNamespace(
      accounts: (fields[0] as List).cast<String>(),
      methods: (fields[1] as List).cast<String>(),
      events: (fields[2] as List).cast<String>(),
      extension: (fields[3] as List?)?.cast<SessionBaseNamespace>(),
    );
  }

  @override
  void write(BinaryWriter writer, SessionNamespace obj) {
    writer
      ..writeByte(4)
      ..writeByte(3)
      ..write(obj.extension)
      ..writeByte(0)
      ..write(obj.accounts)
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
      other is SessionNamespaceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SessionPublicKeyMetadataAdapter
    extends TypeAdapter<SessionPublicKeyMetadata> {
  @override
  final int typeId = 15;

  @override
  SessionPublicKeyMetadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionPublicKeyMetadata(
      publicKey: fields[0] as String,
      metadata: fields[1] as AppMetadata,
    );
  }

  @override
  void write(BinaryWriter writer, SessionPublicKeyMetadata obj) {
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
      other is SessionPublicKeyMetadataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SessionStructAdapter extends TypeAdapter<SessionStruct> {
  @override
  final int typeId = 6;

  @override
  SessionStruct read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionStruct(
      topic: fields[0] as String,
      relay: fields[1] as RelayerProtocolOptions,
      expiry: fields[2] as int,
      acknowledged: fields[3] as bool,
      controller: fields[4] as String,
      namespaces: (fields[5] as Map).cast<String, SessionNamespace>(),
      requiredNamespaces:
          (fields[6] as Map?)?.cast<String, ProposalRequiredNamespace>(),
      self: fields[7] as SessionPublicKeyMetadata,
      peer: fields[8] as SessionPublicKeyMetadata,
    );
  }

  @override
  void write(BinaryWriter writer, SessionStruct obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.topic)
      ..writeByte(1)
      ..write(obj.relay)
      ..writeByte(2)
      ..write(obj.expiry)
      ..writeByte(3)
      ..write(obj.acknowledged)
      ..writeByte(4)
      ..write(obj.controller)
      ..writeByte(5)
      ..write(obj.namespaces)
      ..writeByte(6)
      ..write(obj.requiredNamespaces)
      ..writeByte(7)
      ..write(obj.self)
      ..writeByte(8)
      ..write(obj.peer);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionStructAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionBaseNamespace _$SessionBaseNamespaceFromJson(
        Map<String, dynamic> json) =>
    SessionBaseNamespace(
      accounts:
          (json['accounts'] as List<dynamic>).map((e) => e as String).toList(),
      methods:
          (json['methods'] as List<dynamic>).map((e) => e as String).toList(),
      events:
          (json['events'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$SessionBaseNamespaceToJson(
        SessionBaseNamespace instance) =>
    <String, dynamic>{
      'accounts': instance.accounts,
      'methods': instance.methods,
      'events': instance.events,
    };

SessionNamespace _$SessionNamespaceFromJson(Map<String, dynamic> json) =>
    SessionNamespace(
      accounts:
          (json['accounts'] as List<dynamic>).map((e) => e as String).toList(),
      methods:
          (json['methods'] as List<dynamic>).map((e) => e as String).toList(),
      events:
          (json['events'] as List<dynamic>).map((e) => e as String).toList(),
      extension: (json['extension'] as List<dynamic>?)
          ?.map((e) => SessionBaseNamespace.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SessionNamespaceToJson(SessionNamespace instance) {
  final val = <String, dynamic>{
    'accounts': instance.accounts,
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

SessionPublicKeyMetadata _$SessionPublicKeyMetadataFromJson(
        Map<String, dynamic> json) =>
    SessionPublicKeyMetadata(
      publicKey: json['publicKey'] as String,
      metadata: AppMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SessionPublicKeyMetadataToJson(
        SessionPublicKeyMetadata instance) =>
    <String, dynamic>{
      'publicKey': instance.publicKey,
      'metadata': instance.metadata.toJson(),
    };

SessionStruct _$SessionStructFromJson(Map<String, dynamic> json) =>
    SessionStruct(
      topic: json['topic'] as String,
      relay: RelayerProtocolOptions.fromJson(
          json['relay'] as Map<String, dynamic>),
      expiry: json['expiry'] as int,
      acknowledged: json['acknowledged'] as bool,
      controller: json['controller'] as String,
      namespaces: (json['namespaces'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, SessionNamespace.fromJson(e as Map<String, dynamic>)),
      ),
      requiredNamespaces:
          (json['requiredNamespaces'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            k, ProposalRequiredNamespace.fromJson(e as Map<String, dynamic>)),
      ),
      self: SessionPublicKeyMetadata.fromJson(
          json['self'] as Map<String, dynamic>),
      peer: SessionPublicKeyMetadata.fromJson(
          json['peer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SessionStructToJson(SessionStruct instance) {
  final val = <String, dynamic>{
    'topic': instance.topic,
    'relay': instance.relay.toJson(),
    'expiry': instance.expiry,
    'acknowledged': instance.acknowledged,
    'controller': instance.controller,
    'namespaces': instance.namespaces.map((k, e) => MapEntry(k, e.toJson())),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('requiredNamespaces',
      instance.requiredNamespaces?.map((k, e) => MapEntry(k, e.toJson())));
  val['self'] = instance.self.toJson();
  val['peer'] = instance.peer.toJson();
  return val;
}
