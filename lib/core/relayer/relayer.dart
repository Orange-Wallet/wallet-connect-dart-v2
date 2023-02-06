import 'dart:async';

import 'package:logger/logger.dart';
import 'package:walletconnect_v2/core/i_core.dart';
import 'package:walletconnect_v2/core/messages/i_message_tracker.dart';
import 'package:walletconnect_v2/core/messages/message_tracker.dart';
import 'package:walletconnect_v2/core/publisher/i_publisher.dart';
import 'package:walletconnect_v2/core/publisher/publisher.dart';
import 'package:walletconnect_v2/core/relayer/constants.dart';
import 'package:walletconnect_v2/core/relayer/i_relayer.dart';
import 'package:walletconnect_v2/core/relayer/models.dart';
import 'package:walletconnect_v2/core/subscriber/constants.dart';
import 'package:walletconnect_v2/core/subscriber/i_subscriber.dart';
import 'package:walletconnect_v2/core/subscriber/subscriber.dart';
import 'package:walletconnect_v2/utils/error.dart';
import 'package:walletconnect_v2/utils/misc.dart';
import 'package:walletconnect_v2/wc_utils/jsonrpc/provider/i_json_rpc_provider.dart';
import 'package:walletconnect_v2/wc_utils/jsonrpc/provider/json_rpc_provider.dart';
import 'package:walletconnect_v2/wc_utils/jsonrpc/models/models.dart';
import 'package:walletconnect_v2/wc_utils/jsonrpc/utils/error.dart';
import 'package:walletconnect_v2/wc_utils/jsonrpc/utils/format.dart';
import 'package:walletconnect_v2/wc_utils/jsonrpc/utils/validator.dart';
import 'package:walletconnect_v2/wc_utils/jsonrpc/ws-connection/ws.dart';
import 'package:walletconnect_v2/wc_utils/misc/events/events.dart';
import 'package:walletconnect_v2/wc_utils/relay/models.dart';

class Relayer with Events implements IRelayer {
  final String protocol = "wc";
  final int version = 2;

  @override
  final ICore core;

  @override
  final Logger logger;

  @override
  final String relayUrl;

  @override
  final String? projectId;

  @override
  late final ISubscriber subscriber;

  @override
  late final IPublisher publisher;

  @override
  final IMessageTracker messages;

  @override
  final String name;

  @override
  bool transportExplicitlyClosed;

  IJsonRpcProvider? _provider;

  @override
  IJsonRpcProvider get provider => _provider!;

  @override
  final EventEmitter<String> events;

  bool _initialized = false;

  Relayer({
    required this.core,
    Logger? logger,
    String? relayUrl,
    this.projectId,
  })  : events = EventEmitter(),
        logger = logger ?? Logger(),
        relayUrl = relayUrl ?? RELAYER_DEFAULT_RELAY_URL,
        messages = MessageTracker(core: core, logger: logger),
        name = RELAYER_CONTEXT,
        transportExplicitlyClosed = false {
    subscriber = Subscriber(relayer: this, logger: logger);
    publisher = Publisher(relayer: this, logger: logger);
  }

  @override
  Future<void> init() async {
    logger.i('Initialized');
    _provider = await _createProvider();
    await Future.wait([
      messages.init(),
      provider.connect(),
      subscriber.init(),
    ]);
    _registerEventListeners();
    _initialized = true;
  }

  @override
  bool get connected => provider.connection.connected;

  @override
  bool get connecting => provider.connection.connecting;

  @override
  Future<void> publish({
    required String topic,
    required String message,
    RelayerPublishOptions? opts,
  }) async {
    _isInitialized();
    await publisher.publish(topic: topic, message: message, opts: opts);
    await _recordMessageEvent(
        RelayerMessageEvent(message: message, topic: topic));
  }

  @override
  Future<String> subscribe({
    required String topic,
    RelayerSubscribeOptions? opts,
  }) async {
    _isInitialized();
    final id = await subscriber.subscribe(topic, opts: opts);
    return id;
  }

  @override
  Future<void> unsubscribe({
    required String topic,
    RelayerUnsubscribeOptions? opts,
  }) async {
    _isInitialized();
    await subscriber.unsubscribe(topic, opts: opts);
  }

  @override
  Future<void> transportClose() async {
    transportExplicitlyClosed = true;
    await provider.disconnect();
  }

  @override
  Future<void> transportOpen({String? relayUrl}) async {
    relayUrl = relayUrl ?? relayUrl;
    transportExplicitlyClosed = false;
    await provider.connect();
    // wait for the subscriber to finish resubscribing to its topics
    final completer = Completer<void>();
    subscriber.once(SubscriberEvents.resubscribed, (_) {
      completer.complete();
    });
    return await completer.future;
  }
  // ---------- Private ----------------------------------------------- //

  Future<IJsonRpcProvider> _createProvider() async {
    final auth = await core.crypto.signJWT(relayUrl);
    return JsonRpcProvider(
      WsConnection(
        formatRelayRpcUrl(
          sdkVersion: RELAYER_SDK_VERSION,
          protocol: protocol,
          version: version,
          relayUrl: relayUrl,
          projectId: projectId,
          auth: auth,
        ),
      ),
    );
  }

  Future<void> _recordMessageEvent(RelayerMessageEvent messageEvent) async {
    await messages.set(messageEvent.topic, messageEvent.message);
  }

  Future<bool> _shouldIgnoreMessageEvent(
      RelayerMessageEvent messageEvent) async {
    if (!(await subscriber.isSubscribed(messageEvent.topic))) return true;
    final exists = await messages.has(messageEvent.topic, messageEvent.message);
    return exists;
  }

  Future<void> _onProviderPayload(dynamic payload) async {
    logger.d('Incoming Relay Payload');
    logger.v({
      'type': "payload",
      'direction': "incoming",
      'payload': payload,
    });
    if (isJsonRpcRequest(payload)) {
      final payloadObj = JsonRpcRequest.fromJson(
        payload,
        (v) =>
            RelayJsonRpcSubscriptionParams.fromJson(v as Map<String, dynamic>),
      );
      if (!payloadObj.method.endsWith(RELAYER_SUBSCRIBER_SUFFIX)) return;
      final event = payloadObj.params!;
      final messageEvent = RelayerMessageEvent(
        topic: event.data.topic,
        message: event.data.message,
      );
      logger.d('Emitting Relayer Payload');
      logger.v({
        'type': "event",
        'event': event.id,
        'messageEvent': messageEvent.toJson(),
      });
      events.emit(event.id, messageEvent);
      await _acknowledgePayload<RelayJsonRpcSubscriptionParams>(payloadObj);
      await _onMessageEvent(messageEvent);
    }
  }

  Future<void> _onMessageEvent(RelayerMessageEvent messageEvent) async {
    if (await _shouldIgnoreMessageEvent(messageEvent)) return;
    events.emit(RelayerEvents.message, messageEvent);
    await _recordMessageEvent(messageEvent);
  }

  Future<void> _acknowledgePayload<T>(JsonRpcRequest<T> payload) async {
    final response = formatJsonRpcResult<bool>(
      id: payload.id,
      result: true,
      resultToJson: (v) => v,
    );
    await provider.connection.send(payload: response);
  }

  void _registerEventListeners() {
    provider.on(
      RelayerProviderEvents.payload,
      (payload) => _onProviderPayload(payload),
    );
    provider.on(RelayerProviderEvents.connect, (_) {
      events.emit(RelayerEvents.connect);
    });
    provider.on(RelayerProviderEvents.disconnect, (_) {
      events.emit(RelayerEvents.disconnect);
      _attemptToReconnect();
    });
    provider.on(
      RelayerProviderEvents.error,
      (error) => events.emit(RelayerEvents.error, error),
    );
  }

  void _attemptToReconnect() {
    if (transportExplicitlyClosed) {
      return;
    }
    // Attempt reconnection after one second.
    Timer(const Duration(seconds: RELAYER_RECONNECT_TIMEOUT), () {
      provider.connect();
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
