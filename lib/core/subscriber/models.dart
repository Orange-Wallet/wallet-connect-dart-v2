import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_connect/core/relayer/models.dart';

part 'models.g.dart';

class SubscriberParams extends RelayerSubscribeOptions {
  final String topic;

  SubscriberParams({
    required RelayerProtocolOptions relay,
    required this.topic,
  }) : super(relay: relay);
}

@JsonSerializable()
class SubscriberActive extends SubscriberParams {
  final String id;

  SubscriberActive({
    required this.id,
    required RelayerProtocolOptions relay,
    required String topic,
  }) : super(relay: relay, topic: topic);

  factory SubscriberActive.fromJson(Map<String, dynamic> json) =>
      _$SubscriberActiveFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriberActiveToJson(this);
}
