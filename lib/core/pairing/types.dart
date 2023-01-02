import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';

import 'package:wallet_connect/core/core/types.dart';
import 'package:wallet_connect/core/relayer/types.dart';
import 'package:wallet_connect/core/store/types.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/error.dart';

class PairingTypesStruct {
  final String topic;
  final int expiry;
  final RelayerTypesProtocolOptions relay;
  final bool active;
  final Metadata? peerMetadata;

  PairingTypesStruct({
    required this.topic,
    required this.expiry,
    required this.relay,
    required this.active,
    this.peerMetadata,
  });

  PairingTypesStruct copyWith({
    String? topic,
    int? expiry,
    RelayerTypesProtocolOptions? relay,
    bool? active,
    Metadata? peerMetadata,
  }) {
    return PairingTypesStruct(
      topic: topic ?? this.topic,
      expiry: expiry ?? this.expiry,
      relay: relay ?? this.relay,
      active: active ?? this.active,
      peerMetadata: peerMetadata ?? this.peerMetadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PairingTypesStruct &&
        other.topic == topic &&
        other.expiry == expiry &&
        other.relay == relay &&
        other.active == active &&
        other.peerMetadata == peerMetadata;
  }

  @override
  int get hashCode {
    return topic.hashCode ^
        expiry.hashCode ^
        relay.hashCode ^
        active.hashCode ^
        peerMetadata.hashCode;
  }
}

// -- core ------------------------------------------------------- //
// type DefaultResponse = true | ErrorResponse;

enum PairingJsonRpcWcMethod {
  @JsonValue("wc_pairingDelete")
  WC_PAIRING_DELETE,
  @JsonValue("wc_pairingPing")
  WC_PAIRING_PING,
}

extension PairingJsonRpcWcMethodExt on PairingJsonRpcWcMethod {
  String get value {
    switch (this) {
      case PairingJsonRpcWcMethod.WC_PAIRING_DELETE:
        return "wc_pairingDelete";
      case PairingJsonRpcWcMethod.WC_PAIRING_PING:
        return "wc_pairingPing";
      default:
        throw WCException('Invalid PairingJsonRpcWcMethod');
    }
  }
}

class PairingJsonRpcOptions {
  final RelayerTypesPublishOptions req;
  final RelayerTypesPublishOptions res;

  PairingJsonRpcOptions({required this.req, required this.res});
}
// type Error = ErrorResponse;

// -- requests --------------------------------------------------- //

// interface RequestParams {
//   wc_pairingDelete: {
//     code: number;
//     message: string;
//   };
//   wc_pairingPing: Record<string, unknown>;
// }

// -- responses -------------------------------------------------- //
// interface Results {
//   wc_pairingDelete: true;
//   wc_pairingPing: true;
// }

// -- events ----------------------------------------------------- //
// interface EventCallback<T extends JsonRpcRequest | JsonRpcResponse> {
//   topic: string;
//   payload: T;
// }

class PairingTopicUriData {
  final String topic;
  final String uri;

  PairingTopicUriData({required this.topic, required this.uri});
}

abstract class IPairing {
  String get name;

  IStore<String, PairingTypesStruct> get pairings;

  ICore get core;

  Logger get logger;

  Future<void> init();

  Future<PairingTypesStruct> pair({
    required String uri,
    bool activatePairing = false,
  });

  // for proposer to create inactive pairing
  Future<PairingTopicUriData> create();

  // for either to activate a previously created pairing
  Future<void> activate({required String topic});

  // for both to subscribe on methods requests
  void register(List<String> methods);

  // for either to update the expiry of an existing pairing.
  Future<void> updateExpiry({required String topic, required int expiry});

  // for either to update the metadata of an existing pairing.
  Future<void> updateMetadata(
      {required String topic, required Metadata metadata});

  // query pairings
  List<PairingTypesStruct> getPairings();

  // for either to ping a peer
  Future<void> ping({required String topic});

  // for either peer to disconnect a pairing
  Future<void> disconnect({required String topic});
}

// abstract class IPairingPrivate {
//   sendRequest<M extends PairingJsonRpcTypes.WcMethod>(
//     topic: string,
//     method: M,
//     params: PairingJsonRpcTypes.RequestParams[M],
//   ): Promise<number>;

//   sendResult<M extends PairingJsonRpcTypes.WcMethod>(
//     id: number,
//     topic: string,
//     result: PairingJsonRpcTypes.Results[M],
//   ): Promise<void>;

//   sendError(id: number, topic: string, error: PairingJsonRpcTypes.Error): Promise<void>;

//   onRelayEventRequest(event: PairingJsonRpcTypes.EventCallback<JsonRpcRequest>): void;

//   onRelayEventResponse(event: PairingJsonRpcTypes.EventCallback<JsonRpcResponse>): Promise<void>;

//   onPairingPingRequest(
//     topic: string,
//     payload: JsonRpcRequest<PairingJsonRpcTypes.RequestParams["wc_pairingPing"]>,
//   ): Promise<void>;

//   onPairingPingResponse(
//     topic: string,
//     payload: JsonRpcResult<PairingJsonRpcTypes.Results["wc_pairingPing"]> | JsonRpcError,
//   ): void;

//   onPairingDeleteRequest(
//     topic: string,
//     payload: JsonRpcRequest<PairingJsonRpcTypes.RequestParams["wc_pairingDelete"]>,
//   ): Promise<void>;

//   onUnknownRpcMethodRequest(topic: string, payload: JsonRpcRequest): Promise<void>;

//   onUnknownRpcMethodResponse(method: string): void;

//   deletePairing(topic: string, expirerHasDeleted?: boolean): Promise<void>;
// }
