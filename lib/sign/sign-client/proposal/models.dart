import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_connect/core/models/app_metadata.dart';
import 'package:wallet_connect/core/relayer/models.dart';

part 'models.g.dart';

@JsonSerializable()
@HiveType(typeId: 10)
class ProposalBaseRequiredNamespace {
  @HiveField(0)
  final List<String> chains;
  @HiveField(1)
  final List<String> methods;
  @HiveField(2)
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
@HiveType(typeId: 11)
class ProposalRequiredNamespace extends ProposalBaseRequiredNamespace {
  @HiveField(3)
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
@HiveType(typeId: 12)
class ProposalProposer {
  @HiveField(0)
  final String publicKey;
  @HiveField(1)
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
@HiveType(typeId: 14)
class ProposalRequestStruct {
  @HiveField(0)
  final List<RelayerProtocolOptions> relays;
  @HiveField(1)
  final ProposalProposer proposer;
  @HiveField(2)
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
@HiveType(typeId: 5)
class ProposalStruct extends ProposalRequestStruct {
  @HiveField(3)
  final int id;
  @HiveField(4)
  final int expiry;
  @HiveField(5)
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

// @HiveType(typeId: 5)
// class ProposalStore extends HiveObject {
//   @HiveField(0)
//   final int id;
//   @HiveField(1)
//   final int expiry;
//   @HiveField(2)
//   final List<RelayerProtocolOptions> relays;
//   @HiveField(3)
//   final Map<String, dynamic> proposer;
//   @HiveField(4)
//   final Map<String, dynamic> requiredNamespaces;
//   @HiveField(5)
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
