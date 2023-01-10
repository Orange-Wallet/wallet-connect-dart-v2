import 'dart:async';

import 'package:logger/logger.dart';
import 'package:wallet_connect/core/i_core.dart';
import 'package:wallet_connect/core/messages/messages.dart';
import 'package:wallet_connect/core/messages/types.dart';
import 'package:wallet_connect/core/publisher/publisher.dart';
import 'package:wallet_connect/core/publisher/types.dart';
import 'package:wallet_connect/core/relayer/constants.dart';
import 'package:wallet_connect/core/relayer/types.dart';
import 'package:wallet_connect/core/subscriber/constants.dart';
import 'package:wallet_connect/core/subscriber/subscriber.dart';
import 'package:wallet_connect/core/subscriber/types.dart';
import 'package:wallet_connect/utils/error.dart';
import 'package:wallet_connect/utils/misc.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/provider/provider.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/provider/types.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/types.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/error.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/format.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/validator.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/ws-connection/ws.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';
import 'package:wallet_connect/wc_utils/relay/types.dart';

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
  final EventSubject events;

  bool _initialized = false;

  Relayer({
    required this.core,
    Logger? logger,
    String? relayUrl,
    this.projectId,
  })  : events = EventSubject(),
        logger = logger ?? Logger(),
        relayUrl = relayUrl ?? RELAYER_DEFAULT_RELAY_URL,
        messages = MessageTracker(core: core, logger: logger),
        name = RELAYER_CONTEXT,
        transportExplicitlyClosed = false {
    subscriber = Subscriber(relayer: this, logger: logger);
    publisher = Publisher(relayer: this, logger: logger);
  }

  @override
  init() async {
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
  get connected => provider.connection.connected;

  @override
  get connecting => provider.connection.connecting;

  @override
  publish({
    required String topic,
    required String message,
    RelayerTypesPublishOptions? opts,
  }) async {
    _isInitialized();
    await publisher.publish(topic: topic, message: message, opts: opts);
    await _recordMessageEvent(
        RelayerTypesMessageEvent(message: message, topic: topic));
  }

  @override
  subscribe({
    required String topic,
    RelayerTypesSubscribeOptions? opts,
  }) async {
    _isInitialized();
    final id = await subscriber.subscribe(topic, opts: opts);
    return id;
  }

  @override
  unsubscribe({
    required String topic,
    RelayerTypesUnsubscribeOptions? opts,
  }) async {
    _isInitialized();
    await subscriber.unsubscribe(topic, opts: opts);
  }

  @override
  transportClose() async {
    transportExplicitlyClosed = true;
    await provider.disconnect();
  }

  @override
  transportOpen({String? relayUrl}) async {
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

  _recordMessageEvent(RelayerTypesMessageEvent messageEvent) async {
    await messages.set(messageEvent.topic, messageEvent.message);
  }

  Future<bool> _shouldIgnoreMessageEvent(
      RelayerTypesMessageEvent messageEvent) async {
    if (!(await subscriber.isSubscribed(messageEvent.topic))) return true;
    final exists = await messages.has(messageEvent.topic, messageEvent.message);
    return exists;
  }

  _onProviderPayload(dynamic payload) async {
    logger.d('Incoming Relay Payload');
    logger.i({
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
      final messageEvent = RelayerTypesMessageEvent(
        topic: event.data.topic,
        message: event.data.message,
      );
      logger.d('Emitting Relayer Payload');
      logger.i(
          {'type': "event", 'event': event.id, 'messageEvent': messageEvent});
      events.emitData(event.id, messageEvent);
      await _acknowledgePayload<RelayJsonRpcSubscriptionParams>(payloadObj);
      await _onMessageEvent(messageEvent);
    }
  }

  _onMessageEvent(RelayerTypesMessageEvent messageEvent) async {
    if (await _shouldIgnoreMessageEvent(messageEvent)) return;
    events.emitData(RelayerEvents.message, messageEvent);
    await _recordMessageEvent(messageEvent);
  }

  _acknowledgePayload<T>(JsonRpcRequest<T> payload) async {
    final response = formatJsonRpcResult<bool>(
      id: payload.id,
      result: true,
      resultToJson: (v) => v,
    );
    await provider.connection.send(payload: response);
  }

  _registerEventListeners() {
    provider.on(
      RelayerProviderEvents.payload,
      (payload) => _onProviderPayload(payload.eventData),
    );
    provider.on(RelayerProviderEvents.connect, (_) {
      events.emitData(RelayerEvents.connect);
    });
    provider.on(RelayerProviderEvents.disconnect, (_) {
      events.emitData(RelayerEvents.disconnect);
      _attemptToReconnect();
    });
    provider.on(
      RelayerProviderEvents.error,
      (event) => events.emitData(RelayerEvents.error, event.eventData),
    );
  }

  _attemptToReconnect() {
    if (transportExplicitlyClosed) {
      return;
    }
    // Attempt reconnection after one second.
    Timer(const Duration(seconds: RELAYER_RECONNECT_TIMEOUT), () {
      provider.connect();
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
