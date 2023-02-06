import 'package:logger/logger.dart';
import 'package:wallet_connect_dart_v2/core/relayer/i_relayer.dart';
import 'package:wallet_connect_dart_v2/core/relayer/models.dart';
import 'package:wallet_connect_dart_v2/core/subscriber/models.dart';
import 'package:wallet_connect_dart_v2/core/topicmap/i_topicmap.dart';
import 'package:wallet_connect_dart_v2/wc_utils/misc/events/events.dart';

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
