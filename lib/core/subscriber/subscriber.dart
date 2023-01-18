import 'dart:async';

import 'package:logger/logger.dart';
import 'package:wallet_connect/core/constants.dart';
import 'package:wallet_connect/core/relayer/constants.dart';
import 'package:wallet_connect/core/relayer/i_relayer.dart';
import 'package:wallet_connect/core/relayer/models.dart';
import 'package:wallet_connect/core/subscriber/constants.dart';
import 'package:wallet_connect/core/subscriber/i_subscriber.dart';
import 'package:wallet_connect/core/subscriber/models.dart';
import 'package:wallet_connect/core/topicmap/i_topicmap.dart';
import 'package:wallet_connect/core/topicmap/topicmap.dart';
import 'package:wallet_connect/utils/error.dart';
import 'package:wallet_connect/utils/relay.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/models/models.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/error.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';
import 'package:wallet_connect/wc_utils/misc/heartbeat/constants.dart';
import 'package:wallet_connect/wc_utils/relay/models.dart';

class Subscriber with Events implements ISubscriber {
  @override
  final Map<String, SubscriberActive> subscriptions;

  @override
  final ISubscriberTopicMap topicMap;

  @override
  final String name;

  final String version;

  final Map<String, SubscriberParams> pending;

  @override
  final IRelayer relayer;

  @override
  final Logger logger;

  @override
  final EventEmitter<String> events;

  final String storagePrefix = CORE_STORAGE_PREFIX;

  List<SubscriberActive> _cached;

  bool _initialized;

  final int _pendingSubInterval = 20;

  Subscriber({
    required this.relayer,
    Logger? logger,
  })  : subscriptions = {},
        topicMap = SubscriberTopicMap(),
        name = SUBSCRIBER_CONTEXT,
        version = SUBSCRIBER_STORAGE_VERSION,
        pending = {},
        events = EventEmitter(),
        logger = logger ?? Logger(),
        _cached = [],
        _initialized = false;

  @override
  Future<void> init() async {
    if (!_initialized) {
      logger.i('Initialized');
      await _restart();
      _registerEventListeners();
      _onEnable();
    }
  }

  String get storageKey => '$storagePrefix$version//$name';

  @override
  int get length => subscriptions.length;

  @override
  List<String> get ids => subscriptions.keys.toList();

  @override
  List<SubscriberActive> get values => subscriptions.values.toList();

  @override
  List<String> get topics => topicMap.topics;

  @override
  Future<String> subscribe(
    String topic, {
    RelayerSubscribeOptions? opts,
  }) async {
    _isInitialized();
    logger.d('Subscribing Topic');
    logger.v({
      'type': "method",
      'method': "subscribe",
      'params': {
        'topic': topic,
        'opts': opts?.toJson(),
      },
    });
    try {
      final relay = getRelayProtocolName(opts);
      final params = SubscriberParams(relay: relay, topic: topic);
      pending[topic] = params;
      final id = await _rpcSubscribe(topic, relay);
      _onSubscribe(id, params);
      logger.d('Successfully Subscribed Topic');
      logger.v({
        'type': "method",
        'method': "subscribe",
        'params': {
          'topic': topic,
          'opts': opts?.toJson(),
        },
      });
      return id;
    } catch (e) {
      logger.d('Failed to Subscribe Topic');
      logger.e(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> unsubscribe(
    String topic, {
    RelayerUnsubscribeOptions? opts,
  }) async {
    _isInitialized();
    if (opts?.id != null) {
      await _unsubscribeById(topic, opts!.id!, opts: opts);
    } else {
      await _unsubscribeByTopic(topic, opts: opts);
    }
  }

  @override
  Future<bool> isSubscribed(String topic) async {
    // topic subscription is already resolved
    if (topics.contains(topic)) return true;

    // wait for the subscription to resolve
    final watch = Stopwatch();
    watch.start();

    final completer = Completer<bool>();

    Timer.periodic(Duration(milliseconds: _pendingSubInterval), (timer) {
      if (!pending.containsKey(topic) && topics.contains(topic)) {
        timer.cancel();
        watch.stop();
        completer.complete(true);
      }
      if (watch.elapsedMilliseconds >= PENDING_SUB_RESOLUTION_TIMEOUT) {
        timer.cancel();
        watch.stop();
        completer.complete(false);
      }
    });

    return completer.future;
  }

  // ---------- Private ----------------------------------------------- //

  bool _hasSubscription(String id, String topic) {
    var result = false;
    try {
      final subscription = _getSubscription(id);
      result = subscription.topic == topic;
    } catch (e) {
      // ignore error
    }
    return result;
  }

  void _onEnable() {
    _cached = [];
    _initialized = true;
  }

  void _onDisable() {
    _cached = values;
    subscriptions.clear();
    topicMap.clear();
    _initialized = false;
  }

  Future<void> _unsubscribeByTopic(
    String topic, {
    RelayerUnsubscribeOptions? opts,
  }) async {
    final ids = topicMap.get(topic);
    await Future.wait(ids.map((id) => _unsubscribeById(topic, id, opts: opts)));
  }

  Future<void> _unsubscribeById(
    String topic,
    String id, {
    RelayerUnsubscribeOptions? opts,
  }) async {
    logger.d('Unsubscribing Topic');
    logger.v({
      'type': "method",
      'method': "unsubscribe",
      'params': {
        'topic': topic,
        'id': id,
        'opts': opts?.toJson(),
      },
    });
    try {
      final relay = getRelayProtocolName(opts);
      await _rpcUnsubscribe(topic, id, relay);
      final reason =
          getSdkError(SdkErrorKey.USER_DISCONNECTED, context: '$name, $topic');
      await _onUnsubscribe(topic, id, reason);
      logger.d('Successfully Unsubscribed Topic');
      logger.v({
        'type': "method",
        'method': "unsubscribe",
        'params': {
          'topic': topic,
          'id': id,
          'opts': opts?.toJson(),
        },
      });
    } catch (e) {
      logger.d('Failed to Unsubscribe Topic');
      logger.e(e.toString());
      rethrow;
    }
  }

  Future<dynamic> _rpcSubscribe(String topic, RelayerProtocolOptions relay) {
    final api = getRelayProtocolApi(relay.protocol);
    final request = RequestArguments<RelayJsonRpcSubscribeParams>(
      method: api.subscribe,
      params: RelayJsonRpcSubscribeParams(topic: topic),
      paramsToJson: (value) => value.toJson(),
    );
    logger.d('Outgoing Relay Payload');
    logger.v({
      'type': "payload",
      'direction': "outgoing",
      'request': request.toJson(),
    });
    return relayer.provider
        .request<RelayJsonRpcSubscribeParams>(request: request);
  }

  Future<dynamic> _rpcUnsubscribe(
      String topic, String id, RelayerProtocolOptions relay) {
    final api = getRelayProtocolApi(relay.protocol);
    final request = RequestArguments<RelayJsonRpcUnsubscribeParams>(
      method: api.unsubscribe,
      params: RelayJsonRpcUnsubscribeParams(
        topic: topic,
        id: id,
      ),
      paramsToJson: (value) => value.toJson(),
    );
    logger.d('Outgoing Relay Payload');
    logger.v({
      'type': "payload",
      'direction': "outgoing",
      'request': request.toJson()
    });
    return relayer.provider.request(request: request);
  }

  void _onSubscribe(String id, SubscriberParams params) {
    _setSubscription(
        id,
        SubscriberActive(
          id: id,
          relay: params.relay,
          topic: params.topic,
        ));
    pending.remove(params.topic);
  }

  void _onResubscribe(String id, SubscriberParams params) {
    _addSubscription(
        id,
        SubscriberActive(
          id: id,
          relay: params.relay,
          topic: params.topic,
        ));
    pending.remove(params.topic);
  }

  Future<void> _onUnsubscribe(
      String topic, String id, ErrorResponse reason) async {
    events.removeAllByEvent(id);
    if (_hasSubscription(id, topic)) {
      _deleteSubscription(id, reason);
    }
    await relayer.messages.del(topic);
  }

  Future<void> _setRelayerSubscriptions(
      List<SubscriberActive> subscriptions) async {
    await relayer.core.storage.setItem<List<SubscriberActive>>(
      storageKey,
      subscriptions,
    );
  }

  Future<List<SubscriberActive>?> _getRelayerSubscriptions() async {
    final subscriptions =
        await relayer.core.storage.getItem<List<SubscriberActive>>(
      storageKey,
    );
    return subscriptions;
  }

  void _setSubscription(String id, SubscriberActive subscription) {
    if (subscriptions.containsKey(id)) return;
    logger.d('Setting subscription');
    logger.v({
      'type': "method",
      'method': "setSubscription",
      'id': id,
      'subscription': subscription.toJson(),
    });
    _addSubscription(id, subscription);
  }

  void _addSubscription(String id, SubscriberActive subscription) {
    subscriptions[id] = subscription;
    topicMap.set(subscription.topic, id);
    events.emit(SubscriberEvents.created, subscription.toJson());
  }

  SubscriberActive _getSubscription(String id) {
    logger.d('Getting subscription');
    logger.v({'type': "method", 'method': "getSubscription", 'id': id});
    final subscription = subscriptions[id];
    if (subscription == null) {
      final error = getInternalError(
        InternalErrorKey.NO_MATCHING_KEY,
        context: '$name: $id',
      );
      throw WCException(error.message);
    }
    return subscription;
  }

  void _deleteSubscription(String id, ErrorResponse reason) {
    logger.d('Deleting subscription');
    logger.v({
      'type': "method",
      'method': "deleteSubscription",
      'id': id,
      'reason': reason.toJson(),
    });
    final subscription = _getSubscription(id);
    subscriptions.remove(id);
    topicMap.delete(topic: subscription.topic, id: id);
    events.emit(SubscriberEvents.deleted, {
      ...subscription.toJson(),
      'reason': reason.toJson(),
    });
  }

  Future<void> _restart() async {
    await _restore();
    await _reset();
  }

  Future<void> _persist() async {
    await _setRelayerSubscriptions(values);
    events.emit(SubscriberEvents.sync);
  }

  Future<void> _reset() async {
    if (_cached.isNotEmpty) {
      await Future.wait(
        _cached.map((subscription) => _resubscribe(subscription)),
      );
    }
    events.emit(SubscriberEvents.resubscribed);
  }

  Future<void> _restore() async {
    try {
      final persisted = await _getRelayerSubscriptions();
      if (persisted?.isEmpty ?? true) return;
      if (subscriptions.isNotEmpty) {
        final error = getInternalError(InternalErrorKey.RESTORE_WILL_OVERRIDE,
            context: name);
        logger.e(error.message);
        throw WCException(error.message);
      }
      _cached = persisted!;
      logger.d('Successfully Restored subscriptions for $name');
      logger.v({
        'type': "method",
        'method': "restore",
        'subscriptions': values.map((e) => e.toJson()).toList(),
      });
    } catch (e) {
      logger.d('Failed to Restore subscriptions for $name');
      logger.e(e.toString());
    }
  }

  Future<void> _resubscribe(SubscriberActive subscription) async {
    if (!ids.contains(subscription.id)) {
      final params = SubscriberParams(
          relay: subscription.relay, topic: subscription.topic);
      pending[params.topic] = params;
      final id = await _rpcSubscribe(subscription.topic, subscription.relay);
      _onResubscribe(id, params);
    }
  }

  Future<void> _onConnect() async {
    await _restart();
    _onEnable();
  }

  void _onDisconnect() {
    _onDisable();
  }

  void _checkPending() {
    if (relayer.transportExplicitlyClosed) {
      return;
    }
    pending.values.forEach((params) async {
      final id = await _rpcSubscribe(params.topic, params.relay);
      _onSubscribe(id, params);
    });
  }

  void _registerEventListeners() {
    relayer.core.heartbeat.on(HeartbeatEvents.pulse, (_) {
      _checkPending();
    });
    relayer.provider.on(RelayerProviderEvents.connect, (_) async {
      await _onConnect();
    });
    relayer.provider.on(RelayerProviderEvents.disconnect, (_) async {
      _onDisconnect();
    });
    events.on(SubscriberEvents.created, (createdEvent) async {
      const eventName = SubscriberEvents.created;
      logger.i('Emitting $eventName');
      logger.v({'type': "event", 'event': eventName, 'data': createdEvent});
      await _persist();
    });
    events.on(SubscriberEvents.deleted, (deletedEvent) async {
      const eventName = SubscriberEvents.deleted;
      logger.i('Emitting $eventName');
      logger.v({'type': "event", 'event': eventName, 'data': deletedEvent});
      await _persist();
    });
  }

  void _isInitialized() {
    if (!_initialized) {
      final error =
          getInternalError(InternalErrorKey.NOT_INITIALIZED, context: name);
      throw WCException(error.message);
    }
  }
}
