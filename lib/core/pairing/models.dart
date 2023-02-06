import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_connect_dart_v2/core/models/app_metadata.dart';
import 'package:wallet_connect_dart_v2/core/relayer/models.dart';

part 'models.g.dart';

@JsonSerializable()
class PairingStruct {
  final String topic;

  final int expiry;

  final RelayerProtocolOptions relay;

  final bool active;

  final AppMetadata? peerMetadata;

  PairingStruct({
    required this.topic,
    required this.expiry,
    required this.relay,
    required this.active,
    this.peerMetadata,
  });

  factory PairingStruct.fromJson(Map<String, dynamic> json) =>
      _$PairingStructFromJson(json);

  Map<String, dynamic> toJson() => _$PairingStructToJson(this);

  PairingStruct copyWith({
    String? topic,
    int? expiry,
    RelayerProtocolOptions? relay,
    bool? active,
    AppMetadata? peerMetadata,
  }) {
    return PairingStruct(
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

    return other is PairingStruct &&
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

enum PairingMethod {
  WC_PAIRING_DELETE,
  WC_PAIRING_PING,
}

Map<PairingMethod, String> _pairingMethodMap = {
  PairingMethod.WC_PAIRING_DELETE: "wc_pairingDelete",
  PairingMethod.WC_PAIRING_PING: "wc_pairingPing",
};

extension PairingMethodX on PairingMethod {
  String get value {
    return _pairingMethodMap[this]!;
  }
}

extension PairingMethodStringX on String {
  PairingMethod? toPairingMethod() {
    final entries =
        _pairingMethodMap.entries.where((element) => element.value == this);
    return entries.isNotEmpty ? entries.first.key : null;
  }
}

class PairingJsonRpcOptions {
  final RelayerPublishOptions req;
  final RelayerPublishOptions res;

  const PairingJsonRpcOptions({required this.req, required this.res});
}

class PairingCreated {
  final String topic;
  final String uri;

  PairingCreated({required this.topic, required this.uri});
}

// 
// class PairingStore {
//   
//   final String topic;
//   
//   final int expiry;
//   
//   final RelayerProtocolOptions relay;
//   
//   final bool active;
//   
//   final Map<String, dynamic>? peerMetadata;

//   PairingStore(
//     this.topic,
//     this.expiry,
//     this.relay,
//     this.active,
//     this.peerMetadata,
//   );

//   factory PairingStore.fromData(PairingStruct data) => PairingStore(
//         data.topic,
//         data.expiry,
//         data.relay,
//         data.active,
//         data.peerMetadata?.toJson(),
//       );

//   PairingStruct toData() => PairingStruct(
//         topic: topic,
//         expiry: expiry,
//         relay: relay,
//         active: active,
//         peerMetadata:
//             peerMetadata != null ? AppMetadata.fromJson(peerMetadata!) : null,
//       );
// }
