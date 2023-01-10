import 'dart:async';

import 'package:logger/logger.dart';
import 'package:wallet_connect/core/constants.dart';
import 'package:wallet_connect/core/relayer/constants.dart';
import 'package:wallet_connect/core/relayer/i_relayer.dart';
import 'package:wallet_connect/core/relayer/types.dart';
import 'package:wallet_connect/core/subscriber/constants.dart';
import 'package:wallet_connect/core/subscriber/types.dart';
import 'package:wallet_connect/core/topicmap/topicmap.dart';
import 'package:wallet_connect/utils/error.dart';
import 'package:wallet_connect/utils/relay.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/types.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/error.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';
import 'package:wallet_connect/wc_utils/misc/heartbeat/constants.dart';
import 'package:wallet_connect/wc_utils/relay/types.dart';

class Subscriber with Events implements ISubscriber {
  final Map<String, SubscriberTypesActive> subscriptions;

  final ISubscriberTopicMap topicMap;

  @override
  final String name;

  final String version;

  final Map<String, SubscriberTypesParams> pending;

  final IRelayer relayer;

  final Logger logger;

  @override
  final EventSubject events;

  List<SubscriberTypesActive> _cached = [];
  bool _initialized = false;

  final int _pendingSubInterval = 20;
  final String _storagePrefix = CORE_STORAGE_PREFIX;

  Subscriber({
    required this.relayer,
    Logger? logger,
  })  : subscriptions = {},
        topicMap = SubscriberTopicMap(),
        name = SUBSCRIBER_CONTEXT,
        version = SUBSCRIBER_STORAGE_VERSION,
        pending = {},
        events = EventSubject(),
        logger = logger ?? Logger();

  @override
  Future<void> init() async {
    if (!_initialized) {
      logger.i('Initialized');
      await _restart();
      _registerEventListeners();
      _onEnable();
    }
  }

  String get storageKey => '$_storagePrefix$version//$name';

  @override
  int get length => subscriptions.length;

  @override
  List<String> get ids => subscriptions.keys.toList();

  @override
  get values => subscriptions.values.toList();

  @override
  get topics => topicMap.topics;

  @override
  Future<String> subscribe(
    String topic, {
    RelayerSubscribeOptions? opts,
  }) async {
    _isInitialized();
    logger.d('Subscribing Topic');
    logger.i({
      'type': "method",
      'method': "subscribe",
      'params': {topic, opts}
    });
    try {
      final relay = getRelayProtocolName(opts);
      final params = SubscriberTypesParams(relay: relay, topic: topic);
      pending[topic] = params;
      final id = await _rpcSubscribe(topic, relay);
      _onSubscribe(id, params);
      logger.d('Successfully Subscribed Topic');
      logger.i({
        'type': "method",
        'method': "subscribe",
        'params': {topic, opts}
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

  _onEnable() {
    _cached = [];
    _initialized = true;
  }

  _onDisable() {
    _cached = values;
    subscriptions.clear();
    topicMap.clear();
    _initialized = false;
  }

  _unsubscribeByTopic(
    String topic, {
    RelayerUnsubscribeOptions? opts,
  }) async {
    final ids = topicMap.get(topic);
    await Future.wait(ids.map((id) => _unsubscribeById(topic, id, opts: opts)));
  }

  _unsubscribeById(
    String topic,
    String id, {
    RelayerUnsubscribeOptions? opts,
  }) async {
    logger.d('Unsubscribing Topic');
    logger.i({
      'type': "method",
      'method': "unsubscribe",
      'params': {topic, id, opts}
    });
    try {
      final relay = getRelayProtocolName(opts);
      await _rpcUnsubscribe(topic, id, relay);
      final reason =
          getSdkError(SdkErrorKey.USER_DISCONNECTED, context: '$name, $topic');
      await _onUnsubscribe(topic, id, reason);
      logger.d('Successfully Unsubscribed Topic');
      logger.i({
        'type': "method",
        'method': "unsubscribe",
        'params': {topic, id, opts}
      });
    } catch (e) {
      logger.d('Failed to Unsubscribe Topic');
      logger.e(e.toString());
      rethrow;
    }
  }

  _rpcSubscribe(String topic, RelayerProtocolOptions relay) {
    final api = getRelayProtocolApi(relay.protocol);
    final request = RequestArguments<RelayJsonRpcSubscribeParams>(
      method: api.subscribe,
      params: RelayJsonRpcSubscribeParams(topic: topic),
      paramsToJson: (value) => value.toJson(),
    );
    logger.d('Outgoing Relay Payload');
    logger.i({
      'type': "payload",
      'direction': "outgoing",
      'request': request.toJson(),
    });
    return relayer.provider
        .request<RelayJsonRpcSubscribeParams>(request: request);
  }

  _rpcUnsubscribe(String topic, String id, RelayerProtocolOptions relay) {
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
    logger.i({
      'type': "payload",
      'direction': "outgoing",
      'request': request.toJson()
    });
    return relayer.provider.request(request: request);
  }

  _onSubscribe(String id, SubscriberTypesParams params) {
    _setSubscription(
        id,
        SubscriberTypesActive(
          id: id,
          relay: params.relay,
          topic: params.topic,
        ));
    pending.remove(params.topic);
  }

  _onResubscribe(String id, SubscriberTypesParams params) {
    _addSubscription(
        id,
        SubscriberTypesActive(
          id: id,
          relay: params.relay,
          topic: params.topic,
        ));
    pending.remove(params.topic);
  }

  _onUnsubscribe(String topic, String id, ErrorResponse reason) async {
    // events.removeAllListeners(id); TODO
    if (_hasSubscription(id, topic)) {
      _deleteSubscription(id, reason);
    }
    await relayer.messages.del(topic);
  }

  _setRelayerSubscriptions(List<SubscriberTypesActive> subscriptions) async {
    await relayer.core.storage.setItem<List<SubscriberTypesActive>>(
      storageKey,
      subscriptions,
    );
  }

  _getRelayerSubscriptions() async {
    final subscriptions =
        await relayer.core.storage.getItem<List<SubscriberTypesActive>>(
      storageKey,
    );
    return subscriptions;
  }

  _setSubscription(String id, SubscriberTypesActive subscription) {
    if (subscriptions.containsKey(id)) return;
    logger.d('Setting subscription');
    logger.i({
      'type': "method",
      'method': "setSubscription",
      'id': id,
      'subscription': subscription
    });
    _addSubscription(id, subscription);
  }

  _addSubscription(String id, SubscriberTypesActive subscription) {
    subscriptions[id] = subscription;
    topicMap.set(subscription.topic, id);
    events.emitData(SubscriberEvents.created, subscription);
  }

  _getSubscription(String id) {
    logger.d('Getting subscription');
    logger.i({'type': "method", 'method': "getSubscription", 'id': id});
    final subscription = subscriptions[id];
    if (subscription == null) {
      final error = getInternalError(InternalErrorKey.NO_MATCHING_KEY,
          context: '$name: $id');
      throw WCException(error.message);
    }
    return subscription;
  }

  _deleteSubscription(String id, ErrorResponse reason) {
    logger.d('Deleting subscription');
    logger.i({
      'type': "method",
      'method': "deleteSubscription",
      'id': id,
      'reason': reason
    });
    final subscription = _getSubscription(id);
    subscriptions.remove(id);
    topicMap.delete(topic: subscription.topic, id: id);
    events.emitData(
        SubscriberEvents.deleted,
        SubscriberEventsDeleted(
          id: id,
          relay: subscription.relay,
          topic: subscription.topic,
          reason: reason,
        ));
  }

  _restart() async {
    await _restore();
    await _reset();
  }

  _persist() async {
    await _setRelayerSubscriptions(values);
    events.emitData(SubscriberEvents.sync);
  }

  _reset() async {
    if (_cached.isNotEmpty) {
      await Future.wait(
        _cached.map((subscription) => _resubscribe(subscription)),
      );
    }
    events.emitData(SubscriberEvents.resubscribed);
  }

  _restore() async {
    try {
      final persisted = await _getRelayerSubscriptions();
      if (persisted == null) return;
      if (!persisted.length) return;
      if (subscriptions.isNotEmpty) {
        final error = getInternalError(InternalErrorKey.RESTORE_WILL_OVERRIDE,
            context: name);
        logger.e(error.message);
        throw WCException(error.message);
      }
      _cached = persisted;
      logger.d('Successfully Restored subscriptions for $name');
      logger.i({'type': "method", 'method': "restore", subscriptions: values});
    } catch (e) {
      logger.d('Failed to Restore subscriptions for $name');
      logger.e(e.toString());
    }
  }

  _resubscribe(SubscriberTypesActive subscription) async {
    if (!ids.contains(subscription.id)) {
      final params = SubscriberTypesParams(
          relay: subscription.relay, topic: subscription.topic);
      pending[params.topic] = params;
      final id = await _rpcSubscribe(subscription.topic, subscription.relay);
      _onResubscribe(id, params);
    }
  }

  _onConnect() async {
    await _restart();
    _onEnable();
  }

  _onDisconnect() {
    _onDisable();
  }

  _checkPending() {
    if (relayer.transportExplicitlyClosed) {
      return;
    }
    pending.values.forEach((params) async {
      final id = await _rpcSubscribe(params.topic, params.relay);
      _onSubscribe(id, params);
    });
  }

  _registerEventListeners() {
    relayer.core.heartbeat.on(HeartbeatEvents.pulse, (_) {
      _checkPending();
    });
    relayer.provider.on(RelayerProviderEvents.connect, (_) async {
      await _onConnect();
    });
    relayer.provider.on(RelayerProviderEvents.disconnect, (_) async {
      _onDisconnect();
    });
    events.on(SubscriberEvents.created, null, (createdEvent, _) async {
      const eventName = SubscriberEvents.created;
      logger.i('Emitting $eventName');
      logger.d({'type': "event", 'event': eventName, 'data': createdEvent});
      await _persist();
    });
    events.on(SubscriberEvents.deleted, null, (deletedEvent, _) async {
      const eventName = SubscriberEvents.deleted;
      logger.i('Emitting $eventName');
      logger.d({'type': "event", 'event': eventName, 'data': deletedEvent});
      await _persist();
    });
  }

  _isInitialized() {
    if (!_initialized) {
      final error =
          getInternalError(InternalErrorKey.NOT_INITIALIZED, context: name);
      throw WCException(error.message);
    }
  }
}
