import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

class RelayJsonRpcMethods {
  final String publish;
  final String subscribe;
  final String subscription;
  final String unsubscribe;

  const RelayJsonRpcMethods({
    required this.publish,
    required this.subscribe,
    required this.subscription,
    required this.unsubscribe,
  });
}

@JsonSerializable()
class RelayJsonRpcSubscribeParams {
  final String topic;

  const RelayJsonRpcSubscribeParams({
    required this.topic,
  });

  factory RelayJsonRpcSubscribeParams.fromJson(Map<String, dynamic> json) =>
      _$RelayJsonRpcSubscribeParamsFromJson(json);

  Map<String, dynamic> toJson() => _$RelayJsonRpcSubscribeParamsToJson(this);
}

@JsonSerializable()
class RelayJsonRpcPublishParams {
  final String topic;
  final String message;
  final int ttl;
  final bool? prompt;
  final int? tag;

  const RelayJsonRpcPublishParams({
    required this.topic,
    required this.message,
    required this.ttl,
    this.prompt,
    this.tag,
  });

  factory RelayJsonRpcPublishParams.fromJson(Map<String, dynamic> json) =>
      _$RelayJsonRpcPublishParamsFromJson(json);

  Map<String, dynamic> toJson() => _$RelayJsonRpcPublishParamsToJson(this);
}

@JsonSerializable()
class RelayJsonRpcSubscriptionData {
  final String topic;
  final String message;

  const RelayJsonRpcSubscriptionData({
    required this.topic,
    required this.message,
  });

  factory RelayJsonRpcSubscriptionData.fromJson(Map<String, dynamic> json) =>
      _$RelayJsonRpcSubscriptionDataFromJson(json);

  Map<String, dynamic> toJson() => _$RelayJsonRpcSubscriptionDataToJson(this);
}

@JsonSerializable()
class RelayJsonRpcSubscriptionParams {
  final String id;
  final RelayJsonRpcSubscriptionData data;

  const RelayJsonRpcSubscriptionParams({
    required this.id,
    required this.data,
  });

  factory RelayJsonRpcSubscriptionParams.fromJson(Map<String, dynamic> json) =>
      _$RelayJsonRpcSubscriptionParamsFromJson(json);

  Map<String, dynamic> toJson() => _$RelayJsonRpcSubscriptionParamsToJson(this);
}

@JsonSerializable()
class RelayJsonRpcUnsubscribeParams {
  final String id;
  final String topic;

  const RelayJsonRpcUnsubscribeParams({
    required this.id,
    required this.topic,
  });

  factory RelayJsonRpcUnsubscribeParams.fromJson(Map<String, dynamic> json) =>
      _$RelayJsonRpcUnsubscribeParamsFromJson(json);

  Map<String, dynamic> toJson() => _$RelayJsonRpcUnsubscribeParamsToJson(this);
}
