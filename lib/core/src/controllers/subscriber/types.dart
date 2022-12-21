import 'package:wallet_connect/core/src/controllers/relayer/types.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/types.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';

class SubscriberTypesParams extends RelayerTypesSubscribeOptions {
  final String topic;

  SubscriberTypesParams({
    required RelayerTypesProtocolOptions relay,
    required this.topic,
  }) : super(relay: relay);
}

class SubscriberTypesActive extends SubscriberTypesParams {
  final String id;

  SubscriberTypesActive({
    required this.id,
    required RelayerTypesProtocolOptions relay,
    required String topic,
  }) : super(relay: relay, topic: topic);
}

class SubscriberEventsDeleted extends SubscriberTypesActive {
  final ErrorResponse reason;

  SubscriberEventsDeleted({
    required String id,
    required RelayerTypesProtocolOptions relay,
    required String topic,
    required this.reason,
  }) : super(id: id, relay: relay, topic: topic);
}

abstract class ISubscriberTopicMap {
  List<String> get topics;

  void set(String topic, String id);

  List<String> get(String topic);

  bool exists(String topic, String id);

  void delete({required String topic, String? id});

  void clear();
}

abstract class ISubscriber with IEvents {
  int get length;

  List<String> get ids;

  List<SubscriberTypesActive> get values;

  List<String> get topics;

  String get name;

  Future<void> init();

  Future<String> subscribe(
    String topic, {
    RelayerTypesSubscribeOptions? opts,
  });

  Future<void> unsubscribe(
    String topic, {
    RelayerTypesUnsubscribeOptions? opts,
  });

  Future<bool> isSubscribed(String topic);
}
