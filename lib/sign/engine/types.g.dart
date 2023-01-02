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
