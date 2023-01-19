// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionSettleRequestParams _$SessionSettleRequestParamsFromJson(
        Map<String, dynamic> json) =>
    SessionSettleRequestParams(
      RelayerProtocolOptions.fromJson(json['relay'] as Map<String, dynamic>),
      SessionPublicKeyMetadata.fromJson(
          json['controller'] as Map<String, dynamic>),
      (json['namespaces'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, SessionNamespace.fromJson(e as Map<String, dynamic>)),
      ),
      json['expiry'] as int,
    );

Map<String, dynamic> _$SessionSettleRequestParamsToJson(
        SessionSettleRequestParams instance) =>
    <String, dynamic>{
      'relay': instance.relay.toJson(),
      'controller': instance.controller.toJson(),
      'namespaces': instance.namespaces.map((k, e) => MapEntry(k, e.toJson())),
      'expiry': instance.expiry,
    };

SessionSettleParams _$SessionSettleParamsFromJson(Map<String, dynamic> json) =>
    SessionSettleParams(
      relay: RelayerProtocolOptions.fromJson(
          json['relay'] as Map<String, dynamic>),
      controller: SessionPublicKeyMetadata.fromJson(
          json['controller'] as Map<String, dynamic>),
      namespaces: (json['namespaces'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, SessionNamespace.fromJson(e as Map<String, dynamic>)),
      ),
      requiredNamespaces:
          (json['requiredNamespaces'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, ProposalRequiredNamespace.fromJson(e as Map<String, dynamic>)),
      ),
      expiry: json['expiry'] as int,
    );

Map<String, dynamic> _$SessionSettleParamsToJson(
        SessionSettleParams instance) =>
    <String, dynamic>{
      'relay': instance.relay.toJson(),
      'controller': instance.controller.toJson(),
      'namespaces': instance.namespaces.map((k, e) => MapEntry(k, e.toJson())),
      'requiredNamespaces':
          instance.requiredNamespaces.map((k, e) => MapEntry(k, e.toJson())),
      'expiry': instance.expiry,
    };

SessionConnectParams _$SessionConnectParamsFromJson(
        Map<String, dynamic> json) =>
    SessionConnectParams(
      requiredNamespaces:
          (json['requiredNamespaces'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, ProposalRequiredNamespace.fromJson(e as Map<String, dynamic>)),
      ),
      pairingTopic: json['pairingTopic'] as String?,
      relays: (json['relays'] as List<dynamic>?)
          ?.map(
              (e) => RelayerProtocolOptions.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SessionConnectParamsToJson(
    SessionConnectParams instance) {
  final val = <String, dynamic>{
    'requiredNamespaces':
        instance.requiredNamespaces.map((k, e) => MapEntry(k, e.toJson())),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('pairingTopic', instance.pairingTopic);
  writeNotNull('relays', instance.relays?.map((e) => e.toJson()).toList());
  return val;
}

SessionApproveParams _$SessionApproveParamsFromJson(
        Map<String, dynamic> json) =>
    SessionApproveParams(
      id: json['id'] as int,
      namespaces: (json['namespaces'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, SessionNamespace.fromJson(e as Map<String, dynamic>)),
      ),
      relayProtocol: json['relayProtocol'] as String?,
    );

Map<String, dynamic> _$SessionApproveParamsToJson(
    SessionApproveParams instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'namespaces': instance.namespaces.map((k, e) => MapEntry(k, e.toJson())),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('relayProtocol', instance.relayProtocol);
  return val;
}

SessionRejectParams _$SessionRejectParamsFromJson(Map<String, dynamic> json) =>
    SessionRejectParams(
      id: json['id'] as int,
      reason: ErrorResponse.fromJson(json['reason'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SessionRejectParamsToJson(
        SessionRejectParams instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reason': instance.reason.toJson(),
    };

SessionUpdateParams _$SessionUpdateParamsFromJson(Map<String, dynamic> json) =>
    SessionUpdateParams(
      topic: json['topic'] as String,
      namespaces: (json['namespaces'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, SessionNamespace.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$SessionUpdateParamsToJson(
        SessionUpdateParams instance) =>
    <String, dynamic>{
      'topic': instance.topic,
      'namespaces': instance.namespaces.map((k, e) => MapEntry(k, e.toJson())),
    };

SessionRequestParams _$SessionRequestParamsFromJson(
        Map<String, dynamic> json) =>
    SessionRequestParams(
      topic: json['topic'] as String,
      request: RequestArguments<dynamic>.fromJson(
          json['request'] as Map<String, dynamic>, (value) => value),
      chainId: json['chainId'] as String,
    );

Map<String, dynamic> _$SessionRequestParamsToJson(
        SessionRequestParams instance) =>
    <String, dynamic>{
      'topic': instance.topic,
      'request': instance.request.toJson(),
      'chainId': instance.chainId,
    };

SessionEmitEvent _$SessionEmitEventFromJson(Map<String, dynamic> json) =>
    SessionEmitEvent(
      name: json['name'] as String,
      data: json['data'],
    );

Map<String, dynamic> _$SessionEmitEventToJson(SessionEmitEvent instance) {
  final val = <String, dynamic>{
    'name': instance.name,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('data', instance.data);
  return val;
}
