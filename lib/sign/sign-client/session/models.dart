import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_connect_v2/core/models/app_metadata.dart';
import 'package:wallet_connect_v2/core/relayer/models.dart';
import 'package:wallet_connect_v2/sign/sign-client/proposal/models.dart';

part 'models.g.dart';

@JsonSerializable()
@HiveType(typeId: 8)
class SessionBaseNamespace {
  @HiveField(0)
  final List<String> accounts;
  @HiveField(1)
  final List<String> methods;
  @HiveField(2)
  final List<String> events;

  const SessionBaseNamespace({
    required this.accounts,
    required this.methods,
    required this.events,
  });

  factory SessionBaseNamespace.fromJson(Map<String, dynamic> json) =>
      _$SessionBaseNamespaceFromJson(json);

  Map<String, dynamic> toJson() => _$SessionBaseNamespaceToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SessionBaseNamespace &&
        listEquals(other.accounts, accounts) &&
        listEquals(other.methods, methods) &&
        listEquals(other.events, events);
  }

  @override
  int get hashCode => accounts.hashCode ^ methods.hashCode ^ events.hashCode;
}

@JsonSerializable()
@HiveType(typeId: 9)
class SessionNamespace extends SessionBaseNamespace {
  @HiveField(3)
  final List<SessionBaseNamespace>? extension;

  const SessionNamespace({
    required super.accounts,
    required super.methods,
    required super.events,
    this.extension,
  });

  factory SessionNamespace.fromJson(Map<String, dynamic> json) =>
      _$SessionNamespaceFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SessionNamespaceToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SessionNamespace &&
        listEquals(other.accounts, accounts) &&
        listEquals(other.methods, methods) &&
        listEquals(other.events, events) &&
        listEquals(other.extension, extension);
  }

  @override
  int get hashCode =>
      accounts.hashCode ^
      methods.hashCode ^
      events.hashCode ^
      extension.hashCode;
}

typedef SessionNamespaces = Map<String, SessionNamespace>;

@JsonSerializable()
@HiveType(typeId: 15)
class SessionPublicKeyMetadata {
  @HiveField(0)
  final String publicKey;
  @HiveField(1)
  final AppMetadata metadata;

  SessionPublicKeyMetadata({
    required this.publicKey,
    required this.metadata,
  });

  factory SessionPublicKeyMetadata.fromJson(Map<String, dynamic> json) =>
      _$SessionPublicKeyMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$SessionPublicKeyMetadataToJson(this);

  SessionPublicKeyMetadata copyWith({
    String? publicKey,
    AppMetadata? metadata,
  }) {
    return SessionPublicKeyMetadata(
      publicKey: publicKey ?? this.publicKey,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SessionPublicKeyMetadata &&
        other.publicKey == publicKey &&
        other.metadata == metadata;
  }

  @override
  int get hashCode => publicKey.hashCode ^ metadata.hashCode;
}

@JsonSerializable()
@HiveType(typeId: 6)
class SessionStruct {
  @HiveField(0)
  final String topic;
  @HiveField(1)
  final RelayerProtocolOptions relay;
  @HiveField(2)
  final int expiry;
  @HiveField(3)
  final bool acknowledged;
  @HiveField(4)
  final String controller;
  @HiveField(5)
  final SessionNamespaces namespaces;
  @HiveField(6)
  final ProposalRequiredNamespaces? requiredNamespaces;
  @HiveField(7)
  final SessionPublicKeyMetadata self;
  @HiveField(8)
  final SessionPublicKeyMetadata peer;

  const SessionStruct({
    required this.topic,
    required this.relay,
    required this.expiry,
    required this.acknowledged,
    required this.controller,
    required this.namespaces,
    this.requiredNamespaces,
    required this.self,
    required this.peer,
  });

  factory SessionStruct.fromJson(Map<String, dynamic> json) =>
      _$SessionStructFromJson(json);

  Map<String, dynamic> toJson() => _$SessionStructToJson(this);

  SessionStruct copyWith({
    String? topic,
    RelayerProtocolOptions? relay,
    int? expiry,
    bool? acknowledged,
    String? controller,
    SessionNamespaces? namespaces,
    ProposalRequiredNamespaces? requiredNamespaces,
    SessionPublicKeyMetadata? self,
    SessionPublicKeyMetadata? peer,
  }) {
    return SessionStruct(
      topic: topic ?? this.topic,
      relay: relay ?? this.relay,
      expiry: expiry ?? this.expiry,
      acknowledged: acknowledged ?? this.acknowledged,
      controller: controller ?? this.controller,
      namespaces: namespaces ?? this.namespaces,
      requiredNamespaces: requiredNamespaces ?? this.requiredNamespaces,
      self: self ?? this.self,
      peer: peer ?? this.peer,
    );
  }
}

// @HiveType(typeId: 6)
// class SessionStore extends HiveObject {
//   @HiveField(0)
//   final String topic;
//   @HiveField(1)
//   final RelayerProtocolOptions relay;
//   @HiveField(2)
//   final int expiry;
//   @HiveField(3)
//   final bool acknowledged;
//   @HiveField(4)
//   final String controller;
//   @HiveField(5)
//   final Map<String, dynamic> namespaces;
//   @HiveField(6)
//   final Map<String, dynamic>? requiredNamespaces;
//   @HiveField(7)
//   final Map<String, dynamic> self;
//   @HiveField(8)
//   final Map<String, dynamic> peer;

//   SessionStore(
//     this.topic,
//     this.relay,
//     this.expiry,
//     this.acknowledged,
//     this.controller,
//     this.namespaces,
//     this.requiredNamespaces,
//     this.self,
//     this.peer,
//   );

//   factory SessionStore.fromData(SessionStruct data) => SessionStore(
//         data.topic,
//         data.relay,
//         data.expiry,
//         data.acknowledged,
//         data.controller,
//         data.namespaces.map((k, v) => MapEntry(k, v.toJson())),
//         data.requiredNamespaces?.map((k, v) => MapEntry(k, v.toJson())),
//         data.self.toJson(),
//         data.peer.toJson(),
//       );

//   SessionStruct toData() => SessionStruct(
//         topic: topic,
//         relay: relay,
//         expiry: expiry,
//         acknowledged: acknowledged,
//         controller: controller,
//         namespaces:
//             namespaces.map((k, v) => MapEntry(k, SessionNamespace.fromJson(v))),
//         requiredNamespaces: requiredNamespaces
//             ?.map((k, v) => MapEntry(k, ProposalRequiredNamespace.fromJson(v))),
//         self: SessionPublicKeyMetadata.fromJson(self),
//         peer: SessionPublicKeyMetadata.fromJson(peer),
//       );
// }
