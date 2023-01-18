// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

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
