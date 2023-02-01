// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestSessionRequest _$RequestSessionRequestFromJson(
        Map<String, dynamic> json) =>
    RequestSessionRequest(
      request: RequestArguments<dynamic>.fromJson(
          json['request'] as Map<String, dynamic>, (value) => value),
      chainId: json['chainId'] as String,
    );

Map<String, dynamic> _$RequestSessionRequestToJson(
        RequestSessionRequest instance) =>
    <String, dynamic>{
      'request': instance.request.toJson(),
      'chainId': instance.chainId,
    };

RequestSessionEvent _$RequestSessionEventFromJson(Map<String, dynamic> json) =>
    RequestSessionEvent(
      event: SessionEmitEvent.fromJson(json['event'] as Map<String, dynamic>),
      chainId: json['chainId'] as String,
    );

Map<String, dynamic> _$RequestSessionEventToJson(
        RequestSessionEvent instance) =>
    <String, dynamic>{
      'event': instance.event.toJson(),
      'chainId': instance.chainId,
    };

RequestSessionUpdate _$RequestSessionUpdateFromJson(
        Map<String, dynamic> json) =>
    RequestSessionUpdate(
      namespaces: (json['namespaces'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, SessionNamespace.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$RequestSessionUpdateToJson(
        RequestSessionUpdate instance) =>
    <String, dynamic>{
      'namespaces': instance.namespaces.map((k, e) => MapEntry(k, e.toJson())),
    };

RequestSessionDelete _$RequestSessionDeleteFromJson(
        Map<String, dynamic> json) =>
    RequestSessionDelete(
      code: json['code'] as int,
      message: json['message'] as String,
    );

Map<String, dynamic> _$RequestSessionDeleteToJson(
        RequestSessionDelete instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
    };

RequestSessionPropose _$RequestSessionProposeFromJson(
        Map<String, dynamic> json) =>
    RequestSessionPropose(
      relays: (json['relays'] as List<dynamic>)
          .map(
              (e) => RelayerProtocolOptions.fromJson(e as Map<String, dynamic>))
          .toList(),
      requiredNamespaces:
          (json['requiredNamespaces'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, ProposalRequiredNamespace.fromJson(e as Map<String, dynamic>)),
      ),
      proposer:
          ProposalProposer.fromJson(json['proposer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RequestSessionProposeToJson(
        RequestSessionPropose instance) =>
    <String, dynamic>{
      'relays': instance.relays.map((e) => e.toJson()).toList(),
      'requiredNamespaces':
          instance.requiredNamespaces.map((k, e) => MapEntry(k, e.toJson())),
      'proposer': instance.proposer.toJson(),
    };

ResultSessionPropose _$ResultSessionProposeFromJson(
        Map<String, dynamic> json) =>
    ResultSessionPropose(
      relay: RelayerProtocolOptions.fromJson(
          json['relay'] as Map<String, dynamic>),
      responderPublicKey: json['responderPublicKey'] as String,
    );

Map<String, dynamic> _$ResultSessionProposeToJson(
        ResultSessionPropose instance) =>
    <String, dynamic>{
      'relay': instance.relay.toJson(),
      'responderPublicKey': instance.responderPublicKey,
    };
