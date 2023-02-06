import 'package:json_annotation/json_annotation.dart';
import 'package:walletconnect_v2/core/relayer/models.dart';

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

  final RelayerProtocolOptions relay;

  final String topic;

  SubscriberActive({
    required this.id,
    required this.relay,
    required this.topic,
  }) : super(relay: relay, topic: topic);

  factory SubscriberActive.fromJson(Map<String, dynamic> json) =>
      _$SubscriberActiveFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscriberActiveToJson(this);
}
