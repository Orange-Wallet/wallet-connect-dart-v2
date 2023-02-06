import 'package:flutter/foundation.dart';

import 'package:json_annotation/json_annotation.dart';
import 'package:walletconnect_v2/core/models/app_metadata.dart';
import 'package:walletconnect_v2/core/relayer/models.dart';

part 'models.g.dart';

@JsonSerializable()
class ProposalBaseRequiredNamespace {
  final List<String> chains;

  final List<String> methods;

  final List<String> events;

  const ProposalBaseRequiredNamespace({
    required this.chains,
    required this.methods,
    required this.events,
  });

  factory ProposalBaseRequiredNamespace.fromJson(Map<String, dynamic> json) =>
      _$ProposalBaseRequiredNamespaceFromJson(json);

  Map<String, dynamic> toJson() => _$ProposalBaseRequiredNamespaceToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProposalBaseRequiredNamespace &&
        listEquals(other.chains, chains) &&
        listEquals(other.methods, methods) &&
        listEquals(other.events, events);
  }

  @override
  int get hashCode => chains.hashCode ^ methods.hashCode ^ events.hashCode;
}

@JsonSerializable()
class ProposalRequiredNamespace extends ProposalBaseRequiredNamespace {
  final List<ProposalBaseRequiredNamespace>? extension;

  const ProposalRequiredNamespace({
    required super.chains,
    required super.methods,
    required super.events,
    this.extension,
  });

  factory ProposalRequiredNamespace.fromJson(Map<String, dynamic> json) =>
      _$ProposalRequiredNamespaceFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ProposalRequiredNamespaceToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProposalRequiredNamespace &&
        listEquals(other.chains, chains) &&
        listEquals(other.methods, methods) &&
        listEquals(other.events, events) &&
        listEquals(other.extension, extension);
  }

  @override
  int get hashCode =>
      chains.hashCode ^ methods.hashCode ^ events.hashCode ^ extension.hashCode;
}

typedef ProposalRequiredNamespaces = Map<String, ProposalRequiredNamespace>;

@JsonSerializable()
class ProposalProposer {
  final String publicKey;

  final AppMetadata metadata;

  ProposalProposer({
    required this.publicKey,
    required this.metadata,
  });

  factory ProposalProposer.fromJson(Map<String, dynamic> json) =>
      _$ProposalProposerFromJson(json);

  Map<String, dynamic> toJson() => _$ProposalProposerToJson(this);
}

@JsonSerializable()
class ProposalRequestStruct {
  final List<RelayerProtocolOptions> relays;

  final ProposalProposer proposer;

  final ProposalRequiredNamespaces requiredNamespaces;

  ProposalRequestStruct({
    required this.relays,
    required this.proposer,
    required this.requiredNamespaces,
  });

  factory ProposalRequestStruct.fromJson(Map<String, dynamic> json) =>
      _$ProposalRequestStructFromJson(json);

  Map<String, dynamic> toJson() => _$ProposalRequestStructToJson(this);
}

@JsonSerializable()
class ProposalStruct extends ProposalRequestStruct {
  final int id;

  final int expiry;

  final String? pairingTopic;

  ProposalStruct({
    required this.id,
    required this.expiry,
    required super.relays,
    required super.proposer,
    required super.requiredNamespaces,
    this.pairingTopic,
  });

  factory ProposalStruct.fromJson(Map<String, dynamic> json) =>
      _$ProposalStructFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ProposalStructToJson(this);
}

// 
// class ProposalStore {
//   
//   final int id;
//   
//   final int expiry;
//   
//   final List<RelayerProtocolOptions> relays;
//   
//   final Map<String, dynamic> proposer;
//   
//   final Map<String, dynamic> requiredNamespaces;
//   
//   final String? pairingTopic;

//   ProposalStore(this.id, this.expiry, this.relays, this.proposer,
//       this.requiredNamespaces, this.pairingTopic);

//   factory ProposalStore.fromData(ProposalStruct data) => ProposalStore(
//         data.id,
//         data.expiry,
//         data.relays,
//         data.proposer.toJson(),
//         data.requiredNamespaces.map((k, v) => MapEntry(k, v.toJson())),
//         data.pairingTopic,
//       );

//   ProposalStruct toData() => ProposalStruct(
//         id: id,
//         expiry: expiry,
//         relays: relays,
//         proposer: ProposalProposer.fromJson(proposer),
//         requiredNamespaces: requiredNamespaces
//             .map((k, v) => MapEntry(k, ProposalRequiredNamespace.fromJson(v))),
//         pairingTopic: pairingTopic,
//       );
// }
