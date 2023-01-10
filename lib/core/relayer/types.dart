import 'package:json_annotation/json_annotation.dart';

part 'types.g.dart';

@JsonSerializable()
class RelayerProtocolOptions {
  final String protocol;
  final String? data;

  const RelayerProtocolOptions({
    required this.protocol,
    this.data,
  });

  factory RelayerProtocolOptions.fromJson(Map<String, dynamic> json) =>
      _$RelayerTypesProtocolOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$RelayerTypesProtocolOptionsToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RelayerProtocolOptions &&
        other.protocol == protocol &&
        other.data == data;
  }

  @override
  int get hashCode => protocol.hashCode ^ data.hashCode;
}

class RelayerPublishOptions {
  final RelayerProtocolOptions? relay;
  final int? ttl;
  final bool? prompt;
  final int? tag;

  RelayerPublishOptions({
    this.relay,
    this.ttl,
    this.prompt,
    this.tag,
  });
}

class RelayerSubscribeOptions {
  final RelayerProtocolOptions relay;

  RelayerSubscribeOptions({required this.relay});
}

class RelayerUnsubscribeOptions {
  final String? id;
  final RelayerProtocolOptions relay;

  RelayerUnsubscribeOptions({
    required this.id,
    required this.relay,
  });
}

class RelayerMessageEvent {
  final String topic;
  final String message;

  RelayerMessageEvent({
    required this.topic,
    required this.message,
  });
}

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
