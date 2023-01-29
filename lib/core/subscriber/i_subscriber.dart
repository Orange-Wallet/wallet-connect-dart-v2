import 'package:logger/logger.dart';
import 'package:wallet_connect/core/relayer/i_relayer.dart';
import 'package:wallet_connect/core/relayer/models.dart';
import 'package:wallet_connect/core/subscriber/models.dart';
import 'package:wallet_connect/core/topicmap/i_topicmap.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';

abstract class ISubscriber with IEvents {
  Map<String, SubscriberActive> get subscriptions;

  ISubscriberTopicMap get topicMap;

  int get length;

  List<String> get ids;

  List<SubscriberActive> get values;

  List<String> get topics;

  String get name;

  IRelayer get relayer;

  Logger get logger;

  Future<void> init();

  Future<String> subscribe(
    String topic, {
    RelayerSubscribeOptions? opts,
  });

  Future<void> unsubscribe(
    String topic, {
    RelayerUnsubscribeOptions? opts,
  });

  Future<bool> isSubscribed(String topic);
}
