import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_connect/core/relayer/types.dart';
import 'package:wallet_connect/sign/engine/types.dart';
import 'package:wallet_connect/sign/sign-client/session/types.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/types.dart';

part 'types.g.dart';

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
  final SessionTypesNamespaces namespaces;

  const RpcSessionUpdateParams({
    required this.namespaces,
  });

  factory RpcSessionUpdateParams.fromJson(Map<String, dynamic> json) =>
      _$RpcSessionUpdateParamsFromJson(json);

  Map<String, dynamic> toJson() => _$RpcSessionUpdateParamsToJson(this);
}

// export interface RequestParams {
//   wc_pairingDelete: {
//     code: number;
//     message: string;
//   };
//   wc_pairingPing: Record<string, unknown>;
//   wc_sessionPropose: {
//     relays: RelayerTypes.ProtocolOptions[];
//     requiredNamespaces: ProposalTypes.RequiredNamespaces;
//     proposer: {
//       publicKey: string;
//       metadata: SignClientTypes.Metadata;
//     };
//   };
//   wc_sessionSettle: {
//     relay: RelayerTypes.ProtocolOptions;
//     namespaces: SessionTypes.Namespaces;
//     expiry: number;
//     controller: {
//       publicKey: string;
//       metadata: SignClientTypes.Metadata;
//     };
//   };
//   wc_sessionUpdate: {
//     namespaces: SessionTypes.Namespaces;
//   };
//   wc_sessionExtend: Record<string, unknown>;
//   wc_sessionDelete: {
//     code: number;
//     message: string;
//   };
//   wc_sessionPing: Record<string, unknown>;
//   wc_sessionRequest: {
//     request: {
//       method: string;
//       params: any;
//     };
//     chainId: string;
//   };
//   wc_sessionEvent: {
//     event: {
//       name: string;
//       data: unknown;
//     };
//     chainId: string;
//   };
// }

typedef ResultPairingDelete = bool;
typedef ResultPairingPing = bool;

@JsonSerializable()
class ResultSessionPropose {
  final RelayerTypesProtocolOptions relay;
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
