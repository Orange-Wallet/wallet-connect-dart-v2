// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

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
