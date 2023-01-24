import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_connect_v2/core/relayer/models.dart';

part 'models.g.dart';

class SubscriberParams extends RelayerSubscribeOptions {
  final String topic;

  SubscriberParams({
    required RelayerProtocolOptions relay,
    required this.topic,
  }) : super(relay: relay);
}

@JsonSerializable()
@HiveType(typeId: 2)
class SubscriberActive extends SubscriberParams with HiveObjectMixin {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final RelayerProtocolOptions relay;
  @HiveField(2)
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
