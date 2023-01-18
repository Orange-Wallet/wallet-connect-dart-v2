import 'package:logger/logger.dart';
import 'package:wallet_connect/core/i_core.dart';
import 'package:wallet_connect/core/messages/i_message_tracker.dart';
import 'package:wallet_connect/core/publisher/i_publisher.dart';
import 'package:wallet_connect/core/relayer/models.dart';
import 'package:wallet_connect/core/subscriber/i_subscriber.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/provider/i_json_rpc_provider.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';

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
    RelayerPublishOptions? opts,
  });

  Future<String> subscribe({
    required String topic,
    RelayerSubscribeOptions? opts,
  });

  Future<void> unsubscribe({
    required String topic,
    RelayerUnsubscribeOptions? opts,
  });

  Future<void> transportClose();

  Future<void> transportOpen({String? relayUrl});
}
