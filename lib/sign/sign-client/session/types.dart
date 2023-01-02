import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_connect/core/core/types.dart';
import 'package:wallet_connect/core/relayer/types.dart';
import 'package:wallet_connect/core/store/types.dart';
import 'package:wallet_connect/sign/sign-client/proposal/types.dart';

part 'types.g.dart';

@JsonSerializable()
class SessionTypesBaseNamespace {
  final List<String> accounts;
  final List<String> methods;
  final List<String> events;

  SessionTypesBaseNamespace({
    required this.accounts,
    required this.methods,
    required this.events,
  });

  factory SessionTypesBaseNamespace.fromJson(Map<String, dynamic> json) =>
      _$SessionTypesBaseNamespaceFromJson(json);
}

@JsonSerializable()
class SessionTypesNamespace extends SessionTypesBaseNamespace {
  final List<SessionTypesBaseNamespace>? extension;

  SessionTypesNamespace({
    required super.accounts,
    required super.methods,
    required super.events,
    this.extension,
  });

  factory SessionTypesNamespace.fromJson(Map<String, dynamic> json) =>
      _$SessionTypesNamespaceFromJson(json);
}

typedef SessionTypesNamespaces = Map<String, SessionTypesNamespace>;

@JsonSerializable()
class SessionTypesPublicKeyMetadata {
  final String publicKey;
  final Metadata metadata;

  SessionTypesPublicKeyMetadata({
    required this.publicKey,
    required this.metadata,
  });

  factory SessionTypesPublicKeyMetadata.fromJson(Map<String, dynamic> json) =>
      _$SessionTypesPublicKeyMetadataFromJson(json);

  SessionTypesPublicKeyMetadata copyWith({
    String? publicKey,
    Metadata? metadata,
  }) {
    return SessionTypesPublicKeyMetadata(
      publicKey: publicKey ?? this.publicKey,
      metadata: metadata ?? this.metadata,
    );
  }
}

class SessionTypesStruct {
  final String topic;
  final RelayerTypesProtocolOptions relay;
  final int expiry;
  final bool acknowledged;
  final String controller;
  final SessionTypesNamespaces namespaces;
  final ProposalTypesRequiredNamespaces? requiredNamespaces;
  final SessionTypesPublicKeyMetadata self;
  final SessionTypesPublicKeyMetadata peer;

  SessionTypesStruct({
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

  SessionTypesStruct copyWith({
    String? topic,
    RelayerTypesProtocolOptions? relay,
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
