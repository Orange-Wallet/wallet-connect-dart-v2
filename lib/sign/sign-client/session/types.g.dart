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
        SessionTypesNamespace instance) =>
    <String, dynamic>{
      'accounts': instance.accounts,
      'methods': instance.methods,
      'events': instance.events,
      'extension': instance.extension,
    };

SessionTypesPublicKeyMetadata _$SessionTypesPublicKeyMetadataFromJson(
        Map<String, dynamic> json) =>
    SessionTypesPublicKeyMetadata(
      publicKey: json['publicKey'] as String,
      metadata: Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SessionTypesPublicKeyMetadataToJson(
        SessionTypesPublicKeyMetadata instance) =>
    <String, dynamic>{
      'publicKey': instance.publicKey,
      'metadata': instance.metadata,
    };
