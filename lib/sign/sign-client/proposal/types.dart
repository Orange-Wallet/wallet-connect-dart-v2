import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_connect/core/core/types.dart';
import 'package:wallet_connect/core/relayer/types.dart';
import 'package:wallet_connect/core/store/types.dart';

part 'types.g.dart';

@JsonSerializable()
class ProposalTypesBaseRequiredNamespace {
  final List<String> chains;
  final List<String> methods;
  final List<String> events;

  ProposalTypesBaseRequiredNamespace({
    required this.chains,
    required this.methods,
    required this.events,
  });

  factory ProposalTypesBaseRequiredNamespace.fromJson(
          Map<String, dynamic> json) =>
      _$ProposalTypesBaseRequiredNamespaceFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ProposalTypesBaseRequiredNamespaceToJson(this);
}

@JsonSerializable()
class ProposalTypesRequiredNamespace
    extends ProposalTypesBaseRequiredNamespace {
  final List<ProposalTypesBaseRequiredNamespace>? extension;

  ProposalTypesRequiredNamespace({
    required super.chains,
    required super.methods,
    required super.events,
    this.extension,
  });

  factory ProposalTypesRequiredNamespace.fromJson(Map<String, dynamic> json) =>
      _$ProposalTypesRequiredNamespaceFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ProposalTypesRequiredNamespaceToJson(this);
}

typedef ProposalTypesRequiredNamespaces
    = Map<String, ProposalTypesRequiredNamespace>;

@JsonSerializable()
class ProposalTypesProposer {
  final String publicKey;
  final Metadata metadata;

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
  final List<RelayerTypesProtocolOptions> relays;
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
