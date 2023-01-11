import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:wallet_connect/core/i_core.dart';
import 'package:wallet_connect/core/models/app_metadata.dart';
import 'package:wallet_connect/core/relayer/types.dart';
import 'package:wallet_connect/core/store/i_store.dart';
import 'package:wallet_connect/sign/sign-client/proposal/types.dart';

part 'types.g.dart';

@JsonSerializable()
class SessionTypesBaseNamespace {
  final List<String> accounts;
  final List<String> methods;
  final List<String> events;

  const SessionTypesBaseNamespace({
    required this.accounts,
    required this.methods,
    required this.events,
  });

  factory SessionTypesBaseNamespace.fromJson(Map<String, dynamic> json) =>
      _$SessionTypesBaseNamespaceFromJson(json);

  Map<String, dynamic> toJson() => _$SessionTypesBaseNamespaceToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SessionTypesBaseNamespace &&
        listEquals(other.accounts, accounts) &&
        listEquals(other.methods, methods) &&
        listEquals(other.events, events);
  }

  @override
  int get hashCode => accounts.hashCode ^ methods.hashCode ^ events.hashCode;
}

@JsonSerializable()
class SessionTypesNamespace extends SessionTypesBaseNamespace {
  final List<SessionTypesBaseNamespace>? extension;

  const SessionTypesNamespace({
    required super.accounts,
    required super.methods,
    required super.events,
    this.extension,
  });

  factory SessionTypesNamespace.fromJson(Map<String, dynamic> json) =>
      _$SessionTypesNamespaceFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SessionTypesNamespaceToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SessionTypesNamespace &&
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

typedef SessionTypesNamespaces = Map<String, SessionTypesNamespace>;

@JsonSerializable()
class SessionTypesPublicKeyMetadata {
  final String publicKey;
  final AppMetadata metadata;

  SessionTypesPublicKeyMetadata({
    required this.publicKey,
    required this.metadata,
  });

  factory SessionTypesPublicKeyMetadata.fromJson(Map<String, dynamic> json) =>
      _$SessionTypesPublicKeyMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$SessionTypesPublicKeyMetadataToJson(this);

  SessionTypesPublicKeyMetadata copyWith({
    String? publicKey,
    AppMetadata? metadata,
  }) {
    return SessionTypesPublicKeyMetadata(
      publicKey: publicKey ?? this.publicKey,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SessionTypesPublicKeyMetadata &&
        other.publicKey == publicKey &&
        other.metadata == metadata;
  }

  @override
  int get hashCode => publicKey.hashCode ^ metadata.hashCode;
}

@JsonSerializable()
class SessionTypesStruct {
  final String topic;
  final RelayerProtocolOptions relay;
  final int expiry;
  final bool acknowledged;
  final String controller;
  final SessionTypesNamespaces namespaces;
  final ProposalTypesRequiredNamespaces? requiredNamespaces;
  final SessionTypesPublicKeyMetadata self;
  final SessionTypesPublicKeyMetadata peer;

  const SessionTypesStruct({
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

  factory SessionTypesStruct.fromJson(Map<String, dynamic> json) =>
      _$SessionTypesStructFromJson(json);

  Map<String, dynamic> toJson() => _$SessionTypesStructToJson(this);

  SessionTypesStruct copyWith({
    String? topic,
    RelayerProtocolOptions? relay,
    int? expiry,
    bool? acknowledged,
    String? controller,
    SessionTypesNamespaces? namespaces,
    ProposalTypesRequiredNamespaces? requiredNamespaces,
    SessionTypesPublicKeyMetadata? self,
    SessionTypesPublicKeyMetadata? peer,
  }) {
    return SessionTypesStruct(
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

typedef ISession = IStore<String, SessionTypesStruct>;
