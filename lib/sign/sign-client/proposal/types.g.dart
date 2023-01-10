// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProposalTypesBaseRequiredNamespace _$ProposalTypesBaseRequiredNamespaceFromJson(
        Map<String, dynamic> json) =>
    ProposalTypesBaseRequiredNamespace(
      chains:
          (json['chains'] as List<dynamic>).map((e) => e as String).toList(),
      methods:
          (json['methods'] as List<dynamic>).map((e) => e as String).toList(),
      events:
          (json['events'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ProposalTypesBaseRequiredNamespaceToJson(
        ProposalTypesBaseRequiredNamespace instance) =>
    <String, dynamic>{
      'chains': instance.chains,
      'methods': instance.methods,
      'events': instance.events,
    };

ProposalTypesRequiredNamespace _$ProposalTypesRequiredNamespaceFromJson(
        Map<String, dynamic> json) =>
    ProposalTypesRequiredNamespace(
      chains:
          (json['chains'] as List<dynamic>).map((e) => e as String).toList(),
      methods:
          (json['methods'] as List<dynamic>).map((e) => e as String).toList(),
      events:
          (json['events'] as List<dynamic>).map((e) => e as String).toList(),
      extension: (json['extension'] as List<dynamic>?)
          ?.map((e) => ProposalTypesBaseRequiredNamespace.fromJson(
              e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProposalTypesRequiredNamespaceToJson(
    ProposalTypesRequiredNamespace instance) {
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

ProposalTypesProposer _$ProposalTypesProposerFromJson(
        Map<String, dynamic> json) =>
    ProposalTypesProposer(
      publicKey: json['publicKey'] as String,
      metadata: AppMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProposalTypesProposerToJson(
        ProposalTypesProposer instance) =>
    <String, dynamic>{
      'publicKey': instance.publicKey,
      'metadata': instance.metadata.toJson(),
    };

ProposalTypesRequestStruct _$ProposalTypesRequestStructFromJson(
        Map<String, dynamic> json) =>
    ProposalTypesRequestStruct(
      relays: (json['relays'] as List<dynamic>)
          .map(
              (e) => RelayerProtocolOptions.fromJson(e as Map<String, dynamic>))
          .toList(),
      proposer: ProposalTypesProposer.fromJson(
          json['proposer'] as Map<String, dynamic>),
      requiredNamespaces:
          (json['requiredNamespaces'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k,
            ProposalTypesRequiredNamespace.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$ProposalTypesRequestStructToJson(
        ProposalTypesRequestStruct instance) =>
    <String, dynamic>{
      'relays': instance.relays.map((e) => e.toJson()).toList(),
      'proposer': instance.proposer.toJson(),
      'requiredNamespaces':
          instance.requiredNamespaces.map((k, e) => MapEntry(k, e.toJson())),
    };

ProposalTypesStruct _$ProposalTypesStructFromJson(Map<String, dynamic> json) =>
    ProposalTypesStruct(
      id: json['id'] as int,
      expiry: json['expiry'] as int,
      relays: (json['relays'] as List<dynamic>)
          .map(
              (e) => RelayerProtocolOptions.fromJson(e as Map<String, dynamic>))
          .toList(),
      proposer: ProposalTypesProposer.fromJson(
          json['proposer'] as Map<String, dynamic>),
      requiredNamespaces:
          (json['requiredNamespaces'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k,
            ProposalTypesRequiredNamespace.fromJson(e as Map<String, dynamic>)),
      ),
      pairingTopic: json['pairingTopic'] as String?,
    );

Map<String, dynamic> _$ProposalTypesStructToJson(ProposalTypesStruct instance) {
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
