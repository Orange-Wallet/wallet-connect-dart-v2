import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';
import 'package:wallet_connect/core/i_core.dart';
import 'package:wallet_connect/core/models/app_metadata.dart';
import 'package:wallet_connect/core/relayer/models.dart';
import 'package:wallet_connect/core/store/i_store.dart';

part 'types.g.dart';

@JsonSerializable()
class PairingTypesStruct {
  final String topic;
  final int expiry;
  final RelayerProtocolOptions relay;
  final bool active;
  final AppMetadata? peerMetadata;

  PairingTypesStruct({
    required this.topic,
    required this.expiry,
    required this.relay,
    required this.active,
    this.peerMetadata,
  });

  factory PairingTypesStruct.fromJson(Map<String, dynamic> json) =>
      _$PairingTypesStructFromJson(json);

  Map<String, dynamic> toJson() => _$PairingTypesStructToJson(this);

  PairingTypesStruct copyWith({
    String? topic,
    int? expiry,
    RelayerProtocolOptions? relay,
    bool? active,
    AppMetadata? peerMetadata,
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

enum PairingRpcMethod {
  WC_PAIRING_DELETE,
  WC_PAIRING_PING,
}

Map<PairingRpcMethod, String> _pairingRpcMethodMap = {
  PairingRpcMethod.WC_PAIRING_DELETE: "wc_pairingDelete",
  PairingRpcMethod.WC_PAIRING_PING: "wc_pairingPing",
};

extension PairingRpcMethodExt on PairingRpcMethod {
  String get value {
    return _pairingRpcMethodMap[this]!;
  }
}

extension PairingRpcMethodExtStr on String {
  PairingRpcMethod get pairingRpcMethod {
    return _pairingRpcMethodMap.entries
        .where((element) => element.value == this)
        .first
        .key;
  }
}

class PairingJsonRpcOptions {
  final RelayerPublishOptions req;
  final RelayerPublishOptions res;

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
      {required String topic, required AppMetadata metadata});

  // query pairings
  List<PairingTypesStruct> getPairings();

  // for either to ping a peer
  Future<void> ping({required String topic});

  // for either peer to disconnect a pairing
  Future<void> disconnect({required String topic});
}
