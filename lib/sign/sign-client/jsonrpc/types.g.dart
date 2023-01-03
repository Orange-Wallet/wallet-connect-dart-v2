// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpcSessionRequestParams _$RpcSessionRequestParamsFromJson(
        Map<String, dynamic> json) =>
    RpcSessionRequestParams(
      request: RequestArguments<dynamic>.fromJson(
          json['request'] as Map<String, dynamic>, (value) => value),
      chainId: json['chainId'] as String,
    );

Map<String, dynamic> _$RpcSessionRequestParamsToJson(
        RpcSessionRequestParams instance) =>
    <String, dynamic>{
      'request': instance.request,
      'chainId': instance.chainId,
    };

RpcSessionEventParams _$RpcSessionEventParamsFromJson(
        Map<String, dynamic> json) =>
    RpcSessionEventParams(
      event: SessionEmitEvent.fromJson(json['event'] as Map<String, dynamic>),
      chainId: json['chainId'] as String,
    );

Map<String, dynamic> _$RpcSessionEventParamsToJson(
        RpcSessionEventParams instance) =>
    <String, dynamic>{
      'event': instance.event,
      'chainId': instance.chainId,
    };

RpcSessionUpdateParams _$RpcSessionUpdateParamsFromJson(
        Map<String, dynamic> json) =>
    RpcSessionUpdateParams(
      namespaces: (json['namespaces'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, SessionTypesNamespace.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$RpcSessionUpdateParamsToJson(
        RpcSessionUpdateParams instance) =>
    <String, dynamic>{
      'namespaces': instance.namespaces,
    };

ResultSessionPropose _$ResultSessionProposeFromJson(
        Map<String, dynamic> json) =>
    ResultSessionPropose(
      relay: RelayerTypesProtocolOptions.fromJson(
          json['relay'] as Map<String, dynamic>),
      responderPublicKey: json['responderPublicKey'] as String,
    );

Map<String, dynamic> _$ResultSessionProposeToJson(
        ResultSessionPropose instance) =>
    <String, dynamic>{
      'relay': instance.relay,
      'responderPublicKey': instance.responderPublicKey,
    };
