import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';

import 'package:wallet_connect/core/core/types.dart';
import 'package:wallet_connect/core/messages/types.dart';
import 'package:wallet_connect/core/publisher/types.dart';
import 'package:wallet_connect/core/subscriber/types.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/provider/types.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';

part 'types.g.dart';

@JsonSerializable()
class RelayerTypesProtocolOptions {
  final String protocol;
  final String? data;

  const RelayerTypesProtocolOptions({
    required this.protocol,
    this.data,
  });

  factory RelayerTypesProtocolOptions.fromJson(Map<String, dynamic> json) =>
      _$RelayerTypesProtocolOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$RelayerTypesProtocolOptionsToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RelayerTypesProtocolOptions &&
        other.protocol == protocol &&
        other.data == data;
  }

  @override
  int get hashCode => protocol.hashCode ^ data.hashCode;
}

class RelayerTypesPublishOptions {
  final RelayerTypesProtocolOptions? relay;
  final int? ttl;
  final bool? prompt;
  final int? tag;

  RelayerTypesPublishOptions({
    this.relay,
    this.ttl,
    this.prompt,
    this.tag,
  });
}

class RelayerTypesSubscribeOptions {
  final RelayerTypesProtocolOptions relay;

  RelayerTypesSubscribeOptions({required this.relay});
}

class RelayerTypesUnsubscribeOptions {
  final String? id;
  final RelayerTypesProtocolOptions relay;

  RelayerTypesUnsubscribeOptions({
    required this.id,
    required this.relay,
  });
}

class RelayerTypesMessageEvent {
  final String topic;
  final String message;

  RelayerTypesMessageEvent({
    required this.topic,
    required this.message,
  });
}

// class RelayerTypesRpcUrlParams {
//   final String protocol;
//   final int version;
//   final String auth;
//   final String relayUrl;
//   final String sdkVersion;
//   final String? projectId;

//   RelayerTypesRpcUrlParams({
//     required this.protocol,
//     required this.version,
//     required this.auth,
//     required this.relayUrl,
//     required this.sdkVersion,
//     this.projectId,
//   });
// }

class RelayerClientMetadata {
  final String protocol;
  final int version;
  final String env;
  final String? host;

  RelayerClientMetadata({
    required this.protocol,
    required this.version,
    required this.env,
    this.host,
  });
}

abstract class IRelayer with IEvents {
  ICore get core;

  Logger? get logger;

  String? get relayUrl;

  String? get projectId;

  ISubscriber get subscriber;

  IPublisher get publisher;

  IMessageTracker get messages;

  IJsonRpcProvider get provider;

  String get name;

  bool get transportExplicitlyClosed;

  bool get connected;

  bool get connecting;

  Future<void> init();

  Future<void> publish({
    required String topic,
    required String message,
    RelayerTypesPublishOptions? opts,
  });

  Future<String> subscribe({
    required String topic,
    RelayerTypesSubscribeOptions? opts,
  });

  Future<void> unsubscribe({
    required String topic,
    RelayerTypesUnsubscribeOptions? opts,
  });
  Future<void> transportClose();
  Future<void> transportOpen({String? relayUrl});
}
