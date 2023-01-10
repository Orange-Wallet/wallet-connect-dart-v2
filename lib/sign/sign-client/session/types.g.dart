// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionTypesBaseNamespace _$SessionTypesBaseNamespaceFromJson(
        Map<String, dynamic> json) =>
    SessionTypesBaseNamespace(
      accounts:
          (json['accounts'] as List<dynamic>).map((e) => e as String).toList(),
      methods:
          (json['methods'] as List<dynamic>).map((e) => e as String).toList(),
      events:
          (json['events'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$SessionTypesBaseNamespaceToJson(
        SessionTypesBaseNamespace instance) =>
    <String, dynamic>{
      'accounts': instance.accounts,
      'methods': instance.methods,
      'events': instance.events,
    };

SessionTypesNamespace _$SessionTypesNamespaceFromJson(
        Map<String, dynamic> json) =>
    SessionTypesNamespace(
      accounts:
          (json['accounts'] as List<dynamic>).map((e) => e as String).toList(),
      methods:
          (json['methods'] as List<dynamic>).map((e) => e as String).toList(),
      events:
          (json['events'] as List<dynamic>).map((e) => e as String).toList(),
      extension: (json['extension'] as List<dynamic>?)
          ?.map((e) =>
              SessionTypesBaseNamespace.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SessionTypesNamespaceToJson(
    SessionTypesNamespace instance) {
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

SessionTypesPublicKeyMetadata _$SessionTypesPublicKeyMetadataFromJson(
        Map<String, dynamic> json) =>
    SessionTypesPublicKeyMetadata(
      publicKey: json['publicKey'] as String,
      metadata: AppMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SessionTypesPublicKeyMetadataToJson(
        SessionTypesPublicKeyMetadata instance) =>
    <String, dynamic>{
      'publicKey': instance.publicKey,
      'metadata': instance.metadata.toJson(),
    };

SessionTypesStruct _$SessionTypesStructFromJson(Map<String, dynamic> json) =>
    SessionTypesStruct(
      topic: json['topic'] as String,
      relay: RelayerProtocolOptions.fromJson(
          json['relay'] as Map<String, dynamic>),
      expiry: json['expiry'] as int,
      acknowledged: json['acknowledged'] as bool,
      controller: json['controller'] as String,
      namespaces: (json['namespaces'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, SessionTypesNamespace.fromJson(e as Map<String, dynamic>)),
      ),
      requiredNamespaces:
          (json['requiredNamespaces'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k,
            ProposalTypesRequiredNamespace.fromJson(e as Map<String, dynamic>)),
      ),
      self: SessionTypesPublicKeyMetadata.fromJson(
          json['self'] as Map<String, dynamic>),
      peer: SessionTypesPublicKeyMetadata.fromJson(
          json['peer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SessionTypesStructToJson(SessionTypesStruct instance) {
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
