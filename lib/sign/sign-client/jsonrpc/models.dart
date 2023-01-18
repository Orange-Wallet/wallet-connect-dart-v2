import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_connect/core/relayer/models.dart';
import 'package:wallet_connect/sign/engine/models.dart';
import 'package:wallet_connect/sign/sign-client/proposal/models.dart';
import 'package:wallet_connect/sign/sign-client/session/models.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/models/models.dart';

part 'models.g.dart';

@JsonSerializable()
class RpcSessionRequestParams {
  final RequestArguments request;
  final String chainId;

  const RpcSessionRequestParams({
    required this.request,
    required this.chainId,
  });

  factory RpcSessionRequestParams.fromJson(Map<String, dynamic> json) =>
      _$RpcSessionRequestParamsFromJson(json);

  Map<String, dynamic> toJson() => _$RpcSessionRequestParamsToJson(this);
}

@JsonSerializable()
class RpcSessionEventParams {
  final SessionEmitEvent event;
  final String chainId;

  const RpcSessionEventParams({
    required this.event,
    required this.chainId,
  });

  factory RpcSessionEventParams.fromJson(Map<String, dynamic> json) =>
      _$RpcSessionEventParamsFromJson(json);

  Map<String, dynamic> toJson() => _$RpcSessionEventParamsToJson(this);
}

@JsonSerializable()
class RpcSessionUpdateParams {
  final SessionNamespaces namespaces;

  const RpcSessionUpdateParams({
    required this.namespaces,
  });

  factory RpcSessionUpdateParams.fromJson(Map<String, dynamic> json) =>
      _$RpcSessionUpdateParamsFromJson(json);

  Map<String, dynamic> toJson() => _$RpcSessionUpdateParamsToJson(this);
}

@JsonSerializable()
class RpcSessionProposeParams {
  final List<RelayerProtocolOptions> relays;
  final ProposalRequiredNamespaces requiredNamespaces;
  final ProposalProposer proposer;

  RpcSessionProposeParams({
    required this.relays,
    required this.requiredNamespaces,
    required this.proposer,
  });

  factory RpcSessionProposeParams.fromJson(Map<String, dynamic> json) =>
      _$RpcSessionProposeParamsFromJson(json);

  Map<String, dynamic> toJson() => _$RpcSessionProposeParamsToJson(this);
}

typedef ResultPairingDelete = bool;
typedef ResultPairingPing = bool;

@JsonSerializable()
class ResultSessionPropose {
  final RelayerProtocolOptions relay;
  final String responderPublicKey;

  ResultSessionPropose({
    required this.relay,
    required this.responderPublicKey,
  });

  factory ResultSessionPropose.fromJson(Map<String, dynamic> json) =>
      _$ResultSessionProposeFromJson(json);

  Map<String, dynamic> toJson() => _$ResultSessionProposeToJson(this);
}

typedef ResultSessionSettle = bool;
typedef ResultSessionUpdate = bool;
typedef ResultSessionExtend = bool;
typedef ResultSessionDelete = bool;
typedef ResultSessionPing = bool;
typedef ResultSessionRequest = JsonRpcResult;
typedef ResultSessionEvent = bool;
