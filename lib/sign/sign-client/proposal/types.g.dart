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
        ProposalTypesRequiredNamespace instance) =>
    <String, dynamic>{
      'chains': instance.chains,
      'methods': instance.methods,
      'events': instance.events,
      'extension': instance.extension,
    };

ProposalTypesProposer _$ProposalTypesProposerFromJson(
        Map<String, dynamic> json) =>
    ProposalTypesProposer(
      publicKey: json['publicKey'] as String,
      metadata: Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProposalTypesProposerToJson(
        ProposalTypesProposer instance) =>
    <String, dynamic>{
      'publicKey': instance.publicKey,
      'metadata': instance.metadata,
    };

ProposalTypesRequestStruct _$ProposalTypesRequestStructFromJson(
        Map<String, dynamic> json) =>
    ProposalTypesRequestStruct(
      relays: (json['relays'] as List<dynamic>)
          .map((e) =>
              RelayerTypesProtocolOptions.fromJson(e as Map<String, dynamic>))
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
      'relays': instance.relays,
      'proposer': instance.proposer,
      'requiredNamespaces': instance.requiredNamespaces,
    };
