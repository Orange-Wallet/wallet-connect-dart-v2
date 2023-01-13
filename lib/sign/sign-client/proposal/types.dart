import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_connect/core/models/app_metadata.dart';
import 'package:wallet_connect/core/relayer/models.dart';
import 'package:wallet_connect/core/store/i_store.dart';

part 'types.g.dart';

@JsonSerializable()
class ProposalTypesBaseRequiredNamespace {
  final List<String> chains;
  final List<String> methods;
  final List<String> events;

  const ProposalTypesBaseRequiredNamespace({
    required this.chains,
    required this.methods,
    required this.events,
  });

  factory ProposalTypesBaseRequiredNamespace.fromJson(
          Map<String, dynamic> json) =>
      _$ProposalTypesBaseRequiredNamespaceFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ProposalTypesBaseRequiredNamespaceToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProposalTypesBaseRequiredNamespace &&
        listEquals(other.chains, chains) &&
        listEquals(other.methods, methods) &&
        listEquals(other.events, events);
  }

  @override
  int get hashCode => chains.hashCode ^ methods.hashCode ^ events.hashCode;
}

@JsonSerializable()
class ProposalTypesRequiredNamespace
    extends ProposalTypesBaseRequiredNamespace {
  final List<ProposalTypesBaseRequiredNamespace>? extension;

  const ProposalTypesRequiredNamespace({
    required super.chains,
    required super.methods,
    required super.events,
    this.extension,
  });

  factory ProposalTypesRequiredNamespace.fromJson(Map<String, dynamic> json) =>
      _$ProposalTypesRequiredNamespaceFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ProposalTypesRequiredNamespaceToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProposalTypesRequiredNamespace &&
        listEquals(other.chains, chains) &&
        listEquals(other.methods, methods) &&
        listEquals(other.events, events) &&
        listEquals(other.extension, extension);
  }

  @override
  int get hashCode =>
      chains.hashCode ^ methods.hashCode ^ events.hashCode ^ extension.hashCode;
}

typedef ProposalTypesRequiredNamespaces
    = Map<String, ProposalTypesRequiredNamespace>;

@JsonSerializable()
class ProposalTypesProposer {
  final String publicKey;
  final AppMetadata metadata;

  ProposalTypesProposer({
    required this.publicKey,
    required this.metadata,
  });

  factory ProposalTypesProposer.fromJson(Map<String, dynamic> json) =>
      _$ProposalTypesProposerFromJson(json);

  Map<String, dynamic> toJson() => _$ProposalTypesProposerToJson(this);
}

@JsonSerializable()
class ProposalTypesRequestStruct {
  final List<RelayerProtocolOptions> relays;
  final ProposalTypesProposer proposer;
  final ProposalTypesRequiredNamespaces requiredNamespaces;

  ProposalTypesRequestStruct({
    required this.relays,
    required this.proposer,
    required this.requiredNamespaces,
  });

  factory ProposalTypesRequestStruct.fromJson(Map<String, dynamic> json) =>
      _$ProposalTypesRequestStructFromJson(json);

  Map<String, dynamic> toJson() => _$ProposalTypesRequestStructToJson(this);
}

@JsonSerializable()
class ProposalTypesStruct extends ProposalTypesRequestStruct {
  final int id;
  final int expiry;
  final String? pairingTopic;

  ProposalTypesStruct({
    required this.id,
    required this.expiry,
    required super.relays,
    required super.proposer,
    required super.requiredNamespaces,
    this.pairingTopic,
  });

  factory ProposalTypesStruct.fromJson(Map<String, dynamic> json) =>
      _$ProposalTypesStructFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ProposalTypesStructToJson(this);
}

typedef IProposal = IStore<String, ProposalTypesStruct>;
