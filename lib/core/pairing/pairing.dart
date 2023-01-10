import 'dart:async';

import 'package:logger/logger.dart';
import 'package:wallet_connect/core/core/constants.dart';
import 'package:wallet_connect/core/core/types.dart';
import 'package:wallet_connect/core/expirer/constants.dart';
import 'package:wallet_connect/core/expirer/types.dart';
import 'package:wallet_connect/core/pairing/constants.dart';
import 'package:wallet_connect/core/pairing/types.dart';
import 'package:wallet_connect/core/relayer/constants.dart';
import 'package:wallet_connect/core/relayer/types.dart';
import 'package:wallet_connect/core/store/store.dart';
import 'package:wallet_connect/core/store/types.dart';
import 'package:wallet_connect/sign/engine/types.dart';
import 'package:wallet_connect/utils/crypto.dart';
import 'package:wallet_connect/utils/error.dart';
import 'package:wallet_connect/utils/misc.dart';
import 'package:wallet_connect/utils/uri.dart';
import 'package:wallet_connect/utils/validator.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/types.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/error.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/format.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/validator.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';

class Pairing with Events implements IPairing {
  @override
  final String name = PAIRING_CONTEXT;
  final String version = PAIRING_STORAGE_VERSION;

  @override
  final EventSubject events;

  @override
  final IStore<String, PairingTypesStruct> pairings;

  bool _initialized = false;
  String storagePrefix = CORE_STORAGE_PREFIX;
  List<int> ignoredPayloadTypes = [TYPE_1];
  List<String> registeredMethods = [];

  @override
  final ICore core;

  @override
  final Logger logger;

  final FIVE_MINUTES = 5 * 60; // 5mins in secs
  final THIRTY_DAYS = 30 * 24 * 60 * 60; // 30days in secs

  Pairing({required this.core, Logger? logger})
      : logger = logger ?? Logger(),
        events = EventSubject(),
        pairings = Store(
          core: core,
          logger: logger,
          name: PAIRING_CONTEXT,
          storagePrefix: CORE_STORAGE_PREFIX,
          fromJson: (v) =>
              PairingTypesStruct.fromJson(v as Map<String, dynamic>),
          toJson: (v) => v.toJson(),
        );

  @override
  init() async {
    if (!_initialized) {
      await pairings.init();
      await _cleanup();
      _registerRelayerEvents();
      _registerExpirerEvents();
      _initialized = true;
      logger.i('Initialized');
    }
  }

  @override
  register(List<String> methods) {
    _isInitialized();
    registeredMethods = [
      ...[...registeredMethods, ...methods].toSet()
    ];
  }

  @override
  create() async {
    _isInitialized();
    final symKey = generateRandomBytes32();
    final topic = await core.crypto.setSymKey(symKey: symKey);
    final expiry = calcExpiry(ttl: FIVE_MINUTES);
    final relay =
        RelayerTypesProtocolOptions(protocol: RELAYER_DEFAULT_PROTOCOL);
    final pairing = PairingTypesStruct(
      topic: topic,
      expiry: expiry,
      relay: relay,
      active: false,
    );
    final uri = formatUri(EngineTypesUriParameters(
      protocol: core.protocol,
      version: core.version,
      topic: topic,
      symKey: symKey,
      relay: relay,
    ));
    await pairings.set(topic, pairing);
    await core.relayer.subscribe(topic: topic);
    core.expirer.set(topic, expiry);

    return PairingTopicUriData(topic: topic, uri: uri);
  }

  @override
  pair({
    required String uri,
    bool activatePairing = false,
  }) async {
    _isInitialized();
    _isValidPair(uri);
    final uriParams = parseUri(uri);
    final expiry = calcExpiry(ttl: FIVE_MINUTES);
    final pairing = PairingTypesStruct(
      topic: uriParams.topic,
      expiry: expiry,
      relay: uriParams.relay,
      active: false,
    );
    await pairings.set(uriParams.topic, pairing);
    await core.crypto
        .setSymKey(symKey: uriParams.symKey, overrideTopic: uriParams.topic);
    await core.relayer.subscribe(
      topic: uriParams.topic,
      opts: RelayerTypesSubscribeOptions(relay: uriParams.relay),
    );
    core.expirer.set(uriParams.topic, expiry);

    if (activatePairing) {
      await activate(topic: uriParams.topic);
    }

    return pairing;
  }

  @override
  activate({required String topic}) async {
    _isInitialized();
    final expiry = calcExpiry(ttl: THIRTY_DAYS);
    await pairings.update(
      topic,
      (value) => value.copyWith(active: true, expiry: expiry),
    );
    core.expirer.set(topic, expiry);
  }

  @override
  ping({required String topic}) async {
    _isInitialized();
    await _isValidPairingTopic(topic);
    if (pairings.keys.contains(topic)) {
      final id = await _sendRequest(
          topic, PairingRpcMethod.WC_PAIRING_PING, {}, (_) => {});
      final completer = Completer<void>();
      events.once(engineEvent(EngineTypesEvent.PAIRING_PING, id), null,
          (event, _) {
        if (event.eventData is ErrorResponse) {
          completer.completeError(event.eventData!);
        } else {
          completer.complete();
        }
      });
      await completer.future;
    }
  }

  @override
  updateExpiry({required String topic, required int expiry}) async {
    _isInitialized();
    await pairings.update(topic, (value) => value.copyWith(expiry: expiry));
  }

  @override
  updateMetadata({required String topic, required Metadata metadata}) async {
    _isInitialized();
    await pairings.update(
        topic, (value) => value.copyWith(peerMetadata: metadata));
  }

  @override
  getPairings() {
    _isInitialized();
    return pairings.values;
  }

  @override
  disconnect({required String topic}) async {
    _isInitialized();
    await _isValidPairingTopic(topic);
    if (pairings.keys.contains(topic)) {
      await _sendRequest<ErrorResponse>(
        topic,
        PairingRpcMethod.WC_PAIRING_DELETE,
        getSdkError(SdkErrorKey.USER_DISCONNECTED),
        (e) => e.toJson(),
      );
      await _deletePairing(topic: topic);
    }
  }

  // ---------- Private Helpers ----------------------------------------------- //

  Future<int> _sendRequest<T>(
    String topic,
    PairingRpcMethod method,
    T params,
    Object? Function(T)? paramsToJson,
  ) async {
    final payload = formatJsonRpcRequest<T>(
      method: method.value,
      params: params,
      paramsToJson: paramsToJson,
    );
    final message = await core.crypto.encode(
      topic: topic,
      payload: payload.toJson(),
    );
    final opts = getPairingRpcOptions(method).req;
    core.history.set(topic: topic, request: payload.toJson());
    await core.relayer.publish(topic: topic, message: message, opts: opts);
    return payload.id;
  }

  Future<void> _sendResult<T>(
    int id,
    String topic,
    T result,
    Object? Function(T) resultToJson,
  ) async {
    final payload = formatJsonRpcResult<T>(
      id: id,
      result: result,
      resultToJson: resultToJson,
    );
    final message = await core.crypto.encode(
      topic: topic,
      payload: payload.toJson(),
    );
    final record = core.history.get(topic: topic, id: id);
    final opts = getPairingRpcOptions(
            (record.request['method'] as String).pairingRpcMethod)
        .res;
    await core.relayer.publish(topic: topic, message: message, opts: opts);
    core.history.resolve(payload.toJson());
  }

  Future<void> _sendError(int id, String topic, dynamic error) async {
    final payload = formatJsonRpcError(id: id, error: error);
    final message = await core.crypto.encode(
      topic: topic,
      payload: payload.toJson(),
    );
    final record = core.history.get(topic: topic, id: id);
    final opts = getPairingRpcOptions(
            (record.request['method'] as String).pairingRpcMethod)
        .res;
    await core.relayer.publish(topic: topic, message: message, opts: opts);
    core.history.resolve(payload.toJson());
  }

  _deletePairing({
    required String topic,
    bool expirerHasDeleted = false,
  }) async {
    // Await the unsubscribe first to avoid deleting the symKey too early below.
    await core.relayer.unsubscribe(topic: topic);
    if (!expirerHasDeleted) {
      core.expirer.del(topic);
    }
    await Future.wait([
      pairings.delete(topic, getSdkError(SdkErrorKey.USER_DISCONNECTED)),
      core.crypto.deleteSymKey(topic: topic),
    ]);
  }

  _isInitialized() {
    if (!_initialized) {
      final error =
          getInternalError(InternalErrorKey.NOT_INITIALIZED, context: name);
      throw WCException(error.message);
    }
  }

  _cleanup() async {
    final expiredPairings =
        pairings.getAll().where((pairing) => isExpired(pairing.expiry));
    await Future.wait(
        expiredPairings.map((pairing) => _deletePairing(topic: pairing.topic)));
  }

  // ---------- Relay Events Router ----------------------------------- //

  _registerRelayerEvents() {
    core.relayer.on(RelayerEvents.message, (event) async {
      if (event.eventData is RelayerTypesMessageEvent) {
        final eventData = event.eventData as RelayerTypesMessageEvent;
        final topic = eventData.topic;
        final message = eventData.message;

        // messages of certain types should be ignored as they are handled by their respective SDKs
        if (ignoredPayloadTypes.contains(core.crypto.getPayloadType(message))) {
          return;
        }

        final payload =
            await core.crypto.decode(topic: topic, encoded: message);
        if (isJsonRpcRequest(payload)) {
          core.history.set(topic: topic, request: payload);
          _onRelayEventRequest(topic: topic, payload: payload);
        } else if (isJsonRpcResponse(payload)) {
          core.history.resolve(payload);
          _onRelayEventResponse(topic: topic, payload: payload);
        }
      }
    });
  }

  _onRelayEventRequest({
    required String topic,
    required Map<String, dynamic> payload,
  }) {
    final int id = payload['id'];
    final String reqMethod = payload['method'];

    switch (reqMethod) {
      case "wc_pairingPing":
        return _onPairingPingRequest(topic: topic, id: id);
      case "wc_pairingDelete":
        return _onPairingDeleteRequest(topic: topic, id: id);
      default:
        return _onUnknownRpcMethodRequest(topic: topic, payload: payload);
    }
  }

  _onRelayEventResponse({
    required String topic,
    required Map<String, dynamic> payload,
  }) async {
    final int id = payload['id'];
    final record = core.history.get(topic: topic, id: id);
    final String resMethod = record.request['method'];

    switch (resMethod) {
      case "wc_pairingPing":
        return _onPairingPingResponse(topic: topic, payload: payload);
      default:
        return _onUnknownRpcMethodResponse(resMethod);
    }
  }

  _onPairingPingRequest({
    required String topic,
    required int id,
  }) async {
    try {
      _isValidPairingTopic(topic);
      await _sendResult<bool>(id, topic, true, (v) => v);
      events.emitData(
          EngineTypesEvent.PAIRING_PING.value, {'id': id, 'topic': topic});
    } catch (err) {
      await _sendError(id, topic, err);
      logger.e(err);
    }
  }

  _onPairingPingResponse({
    required String topic,
    required Map<String, dynamic> payload,
  }) async {
    final int id = payload['id'];
    // put at the end of the stack to avoid a race condition
    // where pairing_ping listener is not yet _initialized
    Timer(const Duration(milliseconds: 500), () {
      if (isJsonRpcResult(payload)) {
        events.emitData(engineEvent(
          EngineTypesEvent.PAIRING_PING,
          id,
        ));
      } else if (isJsonRpcError(payload)) {
        events.emitData(
          engineEvent(EngineTypesEvent.PAIRING_PING, id),
          JsonRpcError.fromJson(payload).error,
        );
      }
    });
  }

  _onPairingDeleteRequest({
    required String topic,
    required int id,
  }) async {
    try {
      _isValidPairingTopic(topic);
      // RPC request needs to happen before deletion as it utilises pairing encryption
      await _sendResult<bool>(id, topic, true, (v) => v);
      await _deletePairing(topic: topic);
      events.emitData("pairing_delete", {
        'id': id,
        'topic': topic,
      });
    } catch (err) {
      await _sendError(id, topic, err);
      logger.e(err);
    }
  }

  _onUnknownRpcMethodRequest({
    required String topic,
    required Map<String, dynamic> payload,
  }) async {
    final int id = payload['id'];
    final String method = payload['method'];
    try {
      // Ignore if the implementing client has registered this method as known.
      if (registeredMethods.contains(method)) return;
      final error = getSdkError(
        SdkErrorKey.WC_METHOD_UNSUPPORTED,
        context: method,
      );
      await _sendError(id, topic, error);
      logger.e(error);
    } catch (err) {
      await _sendError(id, topic, err);
      logger.e(err);
    }
  }

  _onUnknownRpcMethodResponse(String method) {
    // Ignore if the implementing client has registered this method as known.
    if (registeredMethods.contains(method)) return;
    logger.e(getSdkError(SdkErrorKey.WC_METHOD_UNSUPPORTED, context: method));
  }

  // ---------- Expirer Events ---------------------------------------- //

  _registerExpirerEvents() {
    core.expirer.on(ExpirerEvents.expired, (event) async {
      if (event.eventData is ExpirerTypesExpiration) {
        final eventData = event.eventData as ExpirerTypesExpiration;
        final expirerTarget = parseExpirerTarget(eventData.target);
        final topic = expirerTarget.topic;
        if (topic != null) {
          if (pairings.keys.contains(topic)) {
            await _deletePairing(topic: topic, expirerHasDeleted: true);
            events.emitData("pairing_expire", {topic});
          }
        }
      }
    });
  }

  // ---------- Validation Helpers ----------------------------------- //

  _isValidPair(String uri) {
    if (!isValidUrl(uri)) {
      final error = getInternalError(InternalErrorKey.MISSING_OR_INVALID,
          context: 'pair() uri: ${uri}');
      throw WCException(error.message);
    }
  }

  _isValidPairingTopic(String topic) async {
    if (!pairings.keys.contains(topic)) {
      final error = getInternalError(
        InternalErrorKey.NO_MATCHING_KEY,
        context: 'pairing topic doesn\'t exist: $topic',
      );
      throw WCException(error.message);
    }
    if (isExpired(pairings.get(topic).expiry)) {
      await _deletePairing(topic: topic);
      final error = getInternalError(InternalErrorKey.EXPIRED,
          context: 'pairing topic: $topic');
      throw WCException(error.message);
    }
  }
}
