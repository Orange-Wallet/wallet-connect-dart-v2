import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

@JsonSerializable()
class RelayerProtocolOptions {
  final String protocol;

  final String? data;

  const RelayerProtocolOptions({
    required this.protocol,
    this.data,
  });

  factory RelayerProtocolOptions.fromJson(Map<String, dynamic> json) =>
      _$RelayerProtocolOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$RelayerProtocolOptionsToJson(this);

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

@JsonSerializable()
class RelayerPublishOptions {
  final RelayerProtocolOptions? relay;
  final int? ttl;
  final bool? prompt;
  final int? tag;

  const RelayerPublishOptions({
    this.relay,
    this.ttl,
    this.prompt,
    this.tag,
  });

  factory RelayerPublishOptions.fromJson(Map<String, dynamic> json) =>
      _$RelayerPublishOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$RelayerPublishOptionsToJson(this);
}

@JsonSerializable()
class RelayerSubscribeOptions {
  final RelayerProtocolOptions relay;

  RelayerSubscribeOptions({required this.relay});

  factory RelayerSubscribeOptions.fromJson(Map<String, dynamic> json) =>
      _$RelayerSubscribeOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$RelayerSubscribeOptionsToJson(this);
}

@JsonSerializable()
class RelayerUnsubscribeOptions {
  final String? id;
  final RelayerProtocolOptions relay;

  RelayerUnsubscribeOptions({
    required this.id,
    required this.relay,
  });

  factory RelayerUnsubscribeOptions.fromJson(Map<String, dynamic> json) =>
      _$RelayerUnsubscribeOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$RelayerUnsubscribeOptionsToJson(this);
}

@JsonSerializable()
class RelayerMessageEvent {
  final String topic;
  final String message;

  RelayerMessageEvent({
    required this.topic,
    required this.message,
  });

  factory RelayerMessageEvent.fromJson(Map<String, dynamic> json) =>
      _$RelayerMessageEventFromJson(json);

  Map<String, dynamic> toJson() => _$RelayerMessageEventToJson(this);
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
