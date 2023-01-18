import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_connect/core/relayer/models.dart';
import 'package:wallet_connect/sign/sign-client/proposal/models.dart';
import 'package:wallet_connect/sign/sign-client/session/models.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/types.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/error.dart';

part 'models.g.dart';

class EngineUriParameters {
  final String protocol;
  final int version;
  final String topic;
  final String symKey;
  final RelayerProtocolOptions relay;

  EngineUriParameters({
    required this.protocol,
    required this.version,
    required this.topic,
    required this.symKey,
    required this.relay,
  });
}

@JsonSerializable()
class SessionSettleRequestParams {
  final RelayerProtocolOptions relay;
  final SessionPublicKeyMetadata controller;
  final SessionNamespaces namespaces;
  final int expiry;

  SessionSettleRequestParams(
    this.relay,
    this.controller,
    this.namespaces,
    this.expiry,
  );

  factory SessionSettleRequestParams.fromJson(Map<String, dynamic> json) =>
      _$SessionSettleRequestParamsFromJson(json);

  Map<String, dynamic> toJson() => _$SessionSettleRequestParamsToJson(this);
}

@JsonSerializable()
class SessionSettleParams {
  final RelayerProtocolOptions relay;
  final SessionPublicKeyMetadata controller;
  final SessionNamespaces namespaces;
  final ProposalRequiredNamespaces requiredNamespaces;
  final int expiry;

  SessionSettleParams({
    required this.relay,
    required this.controller,
    required this.namespaces,
    required this.requiredNamespaces,
    required this.expiry,
  });

  factory SessionSettleParams.fromJson(Map<String, dynamic> json) =>
      _$SessionSettleParamsFromJson(json);

  Map<String, dynamic> toJson() => _$SessionSettleParamsToJson(this);
}

@JsonSerializable()
class SessionConnectParams {
  final ProposalRequiredNamespaces requiredNamespaces;
  final String? pairingTopic;
  final List<RelayerProtocolOptions>? relays;

  SessionConnectParams({
    required this.requiredNamespaces,
    this.pairingTopic,
    this.relays,
  });

  factory SessionConnectParams.fromJson(Map<String, dynamic> json) =>
      _$SessionConnectParamsFromJson(json);
}

@JsonSerializable()
class SessionApproveParams {
  final int id;
  final SessionNamespaces namespaces;
  final String? relayProtocol;

  SessionApproveParams({
    required this.id,
    required this.namespaces,
    this.relayProtocol,
  });

  factory SessionApproveParams.fromJson(Map<String, dynamic> json) =>
      _$SessionApproveParamsFromJson(json);
}

@JsonSerializable()
class SessionRejectParams {
  final int id;
  final ErrorResponse reason;

  SessionRejectParams({
    required this.id,
    required this.reason,
  });

  factory SessionRejectParams.fromJson(Map<String, dynamic> json) =>
      _$SessionRejectParamsFromJson(json);
}

@JsonSerializable()
class SessionUpdateParams {
  final String topic;
  final SessionNamespaces namespaces;

  SessionUpdateParams({
    required this.topic,
    required this.namespaces,
  });

  factory SessionUpdateParams.fromJson(Map<String, dynamic> json) =>
      _$SessionUpdateParamsFromJson(json);
}

class SessionRequestParams {
  final String topic;
  final RequestArguments request;
  final String chainId;

  SessionRequestParams({
    required this.topic,
    required this.request,
    required this.chainId,
  });
}

class SessionRespondParams {
  final String topic;
  final JsonRpcResponse response;

  SessionRespondParams({
    required this.topic,
    required this.response,
  });
}

class SessionEmitParams {
  final String topic;
  final SessionEmitEvent event;
  final String chainId;

  SessionEmitParams({
    required this.topic,
    required this.event,
    required this.chainId,
  });
}

@JsonSerializable()
class SessionEmitEvent {
  final String name;
  final dynamic data;

  const SessionEmitEvent({
    required this.name,
    required this.data,
  });

  factory SessionEmitEvent.fromJson(Map<String, dynamic> json) =>
      _$SessionEmitEventFromJson(json);

  Map<String, dynamic> toJson() => _$SessionEmitEventToJson(this);
}

enum EngineEvent {
  SESSION_CONNECT,
  SESSION_APPROVE,
  SESSION_UPDATE,
  SESSION_EXTEND,
  SESSION_PING,
  PAIRING_PING,
  SESSION_REQUEST,
}

extension EngineEventX on EngineEvent {
  String get value {
    switch (this) {
      case EngineEvent.SESSION_CONNECT:
        return "session_connect";
      case EngineEvent.SESSION_APPROVE:
        return "session_approve";
      case EngineEvent.SESSION_UPDATE:
        return "session_update";
      case EngineEvent.SESSION_EXTEND:
        return "session_extend";
      case EngineEvent.SESSION_PING:
        return "session_ping";
      case EngineEvent.PAIRING_PING:
        return "pairing_ping";
      case EngineEvent.SESSION_REQUEST:
        return "session_request";
      default:
        throw WCException('Invalid EngineTypesEvent');
    }
  }
}

enum JsonRpcMethod {
  WC_SESSION_PROPOSE,
  WC_SESSION_SETTLE,
  WC_SESSION_REQUEST,
  WC_SESSION_DELETE,
  WC_SESSION_PING,
  WC_SESSION_EVENT,
  WC_SESSION_UPDATE,
  WC_SESSION_EXTEND,
}

Map<JsonRpcMethod, String> _jsonRpcMethodMap = {
  JsonRpcMethod.WC_SESSION_PROPOSE: "wc_sessionPropose",
  JsonRpcMethod.WC_SESSION_SETTLE: "wc_sessionSettle",
  JsonRpcMethod.WC_SESSION_REQUEST: "wc_sessionRequest",
  JsonRpcMethod.WC_SESSION_DELETE: "wc_sessionDelete",
  JsonRpcMethod.WC_SESSION_PING: "wc_sessionPing",
  JsonRpcMethod.WC_SESSION_EVENT: "wc_sessionEvent",
  JsonRpcMethod.WC_SESSION_UPDATE: "wc_sessionUpdate",
  JsonRpcMethod.WC_SESSION_EXTEND: "wc_sessionExtend",
};

extension JsonRpcMethodExt on JsonRpcMethod {
  String get value {
    return _jsonRpcMethodMap[this]!;
  }
}

extension JsonRpcMethodExtStr on String {
  JsonRpcMethod? get jsonRpcMethod {
    try {
      return _jsonRpcMethodMap.entries
          .where((element) => element.value == this)
          .first
          .key;
    } catch (e) {
      return null;
    }
  }
}

class EngineConnection {
  final String? uri;
  final Future<SessionStruct>? approval;

  const EngineConnection({
    this.uri,
    this.approval,
  });
}

class EngineApproved {
  final String topic;
  final Future<SessionStruct> acknowledged;

  EngineApproved({
    required this.topic,
    required this.acknowledged,
  });
}

class EngineAcknowledged {
  final Future<void> acknowledged;

  EngineAcknowledged({
    required this.acknowledged,
  });
}
