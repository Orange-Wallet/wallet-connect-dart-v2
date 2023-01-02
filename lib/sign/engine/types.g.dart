// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionSettleRequestParams _$SessionSettleRequestParamsFromJson(
        Map<String, dynamic> json) =>
    SessionSettleRequestParams(
      RelayerTypesProtocolOptions.fromJson(
          json['relay'] as Map<String, dynamic>),
      SessionTypesPublicKeyMetadata.fromJson(
          json['controller'] as Map<String, dynamic>),
      (json['namespaces'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, SessionTypesNamespace.fromJson(e as Map<String, dynamic>)),
      ),
      json['expiry'] as int,
    );

Map<String, dynamic> _$SessionSettleRequestParamsToJson(
        SessionSettleRequestParams instance) =>
    <String, dynamic>{
      'relay': instance.relay,
      'controller': instance.controller,
      'namespaces': instance.namespaces,
      'expiry': instance.expiry,
    };

SessionSettleParams _$SessionSettleParamsFromJson(Map<String, dynamic> json) =>
    SessionSettleParams(
      relay: RelayerTypesProtocolOptions.fromJson(
          json['relay'] as Map<String, dynamic>),
      controller: SessionTypesPublicKeyMetadata.fromJson(
          json['controller'] as Map<String, dynamic>),
      namespaces: (json['namespaces'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, SessionTypesNamespace.fromJson(e as Map<String, dynamic>)),
      ),
      requiredNamespaces:
          (json['requiredNamespaces'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k,
            ProposalTypesRequiredNamespace.fromJson(e as Map<String, dynamic>)),
      ),
      expiry: json['expiry'] as int,
    );

Map<String, dynamic> _$SessionSettleParamsToJson(
        SessionSettleParams instance) =>
    <String, dynamic>{
      'relay': instance.relay,
      'controller': instance.controller,
      'namespaces': instance.namespaces,
      'requiredNamespaces': instance.requiredNamespaces,
      'expiry': instance.expiry,
    };

SessionConnectParams _$SessionConnectParamsFromJson(
        Map<String, dynamic> json) =>
    SessionConnectParams(
      requiredNamespaces:
          (json['requiredNamespaces'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k,
            ProposalTypesRequiredNamespace.fromJson(e as Map<String, dynamic>)),
      ),
      pairingTopic: json['pairingTopic'] as String?,
      relays: (json['relays'] as List<dynamic>?)
          ?.map((e) =>
              RelayerTypesProtocolOptions.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SessionConnectParamsToJson(
        SessionConnectParams instance) =>
    <String, dynamic>{
      'requiredNamespaces': instance.requiredNamespaces,
      'pairingTopic': instance.pairingTopic,
      'relays': instance.relays,
    };

SessionApproveParams _$SessionApproveParamsFromJson(
        Map<String, dynamic> json) =>
    SessionApproveParams(
      id: json['id'] as int,
      namespaces: (json['namespaces'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, SessionTypesNamespace.fromJson(e as Map<String, dynamic>)),
      ),
      relayProtocol: json['relayProtocol'] as String?,
    );

Map<String, dynamic> _$SessionApproveParamsToJson(
        SessionApproveParams instance) =>
    <String, dynamic>{
      'id': instance.id,
      'namespaces': instance.namespaces,
      'relayProtocol': instance.relayProtocol,
    };

SessionRejectParams _$SessionRejectParamsFromJson(Map<String, dynamic> json) =>
    SessionRejectParams(
      id: json['id'] as int,
      reason: ErrorResponse.fromJson(json['reason'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SessionRejectParamsToJson(
        SessionRejectParams instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reason': instance.reason,
    };

SessionUpdateParams _$SessionUpdateParamsFromJson(Map<String, dynamic> json) =>
    SessionUpdateParams(
      topic: json['topic'] as String,
      namespaces: (json['namespaces'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, SessionTypesNamespace.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$SessionUpdateParamsToJson(
        SessionUpdateParams instance) =>
    <String, dynamic>{
      'topic': instance.topic,
      'namespaces': instance.namespaces,
    };

SessionEmitEvent _$SessionEmitEventFromJson(Map<String, dynamic> json) =>
    SessionEmitEvent(
      name: json['name'] as String,
      data: json['data'],
    );

Map<String, dynamic> _$SessionEmitEventToJson(SessionEmitEvent instance) =>
    <String, dynamic>{
      'name': instance.name,
      'data': instance.data,
    };
