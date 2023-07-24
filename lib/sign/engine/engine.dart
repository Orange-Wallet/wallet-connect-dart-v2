import 'dart:async';

import 'package:wallet_connect_dart_v2/core/expirer/constants.dart';
import 'package:wallet_connect_dart_v2/core/expirer/models.dart';
import 'package:wallet_connect_dart_v2/core/pairing/models.dart';
import 'package:wallet_connect_dart_v2/core/relayer/constants.dart';
import 'package:wallet_connect_dart_v2/core/relayer/models.dart';
import 'package:wallet_connect_dart_v2/sign/engine/constants.dart';
import 'package:wallet_connect_dart_v2/sign/engine/i_engine.dart';
import 'package:wallet_connect_dart_v2/sign/engine/models.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/client/i_sign_client.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/client/models.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/jsonrpc/models.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/pending_request/models.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/proposal/models.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/session/constants.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/session/models.dart';
import 'package:wallet_connect_dart_v2/utils/crypto.dart';
import 'package:wallet_connect_dart_v2/utils/error.dart';
import 'package:wallet_connect_dart_v2/utils/misc.dart';
import 'package:wallet_connect_dart_v2/utils/timeout_completer.dart';
import 'package:wallet_connect_dart_v2/utils/validator.dart';
import 'package:wallet_connect_dart_v2/wc_utils/jsonrpc/models/models.dart';
import 'package:wallet_connect_dart_v2/wc_utils/jsonrpc/utils/error.dart';
import 'package:wallet_connect_dart_v2/wc_utils/jsonrpc/utils/format.dart';
import 'package:wallet_connect_dart_v2/wc_utils/jsonrpc/utils/validator.dart';
import 'package:wallet_connect_dart_v2/wc_utils/misc/events/events.dart';

class Engine with Events implements IEngine {
  final String name = ENGINE_CONTEXT;

  @override
  final EventEmitter<String> events;

  bool _initialized;

  final List<int> _ignoredPayloadTypes = [TYPE_1];

  @override
  final ISignClient client;

  Engine({required this.client})
      : events = EventEmitter(),
        _initialized = false;

  @override
  Future<void> init() async {
    if (!_initialized) {
      await _cleanup();
      _registerRelayerEvents();
      _registerExpirerEvents();
      client.core.pairing
          .register(JsonRpcMethod.values.map((e) => e.value).toList());
      _initialized = true;
    }
  }

  // ---------- Public ------------------------------------------------ //
  @override
  Future<EngineConnection> connect(SessionConnectParams params) async {
    _isInitialized();
    await _isValidConnect(params);

    String? topic = params.pairingTopic;
    String? uri;
    bool active = false;

    if (topic != null) {
      final pairing = client.core.pairing.pairings.get(topic);
      active = pairing.active;
    }

    if (topic == null || !active) {
      final pairingData = await client.core.pairing.create();
      topic = pairingData.topic;
      uri = pairingData.uri;
    }

    final publicKey = await client.core.crypto.generateKeyPair();

    final proposal = ProposalRequestStruct(
      requiredNamespaces: params.requiredNamespaces,
      relays: params.relays ??
          [RelayerProtocolOptions(protocol: RELAYER_DEFAULT_PROTOCOL)],
      proposer: ProposalProposer(
        publicKey: publicKey,
        metadata: client.metadata,
      ),
    );

    final completer = Completer<SessionStruct>();
    final timer = completer.expirer();
    events.once(
      engineEvent(EngineEvent.SESSION_CONNECT),
      (data) async {
        timer.cancel();
        if (data is ErrorResponse) {
          completer.completeError(data.toString());
        } else if (data is SessionStruct) {
          final SessionStruct session = data;
          final completeSession = session.copyWith(
            self: session.self.copyWith(publicKey: publicKey),
            requiredNamespaces: params.requiredNamespaces,
          );
          await client.session.set(session.topic, completeSession);
          await _setExpiry(session.topic, session.expiry);
          if (topic != null) {
            await client.core.pairing.updateMetadata(
              topic: topic,
              metadata: session.peer.metadata,
            );
          }
          completer.complete(completeSession);
        }
      },
    );

    // if (topic == null) {
    //   final error = getInternalError(InternalErrorKey.NO_MATCHING_KEY,
    //       context: 'connect() pairing topic: ${topic}');
    //   throw WCException(error.message);
    // }

    final id = await _sendRequest<ProposalRequestStruct>(
      topic,
      JsonRpcMethod.WC_SESSION_PROPOSE,
      proposal,
      (v) => v.toJson(),
    );

    final expiry = calcExpiry(ttl: FIVE_MINUTES);
    await _setProposal(
      id.toString(),
      ProposalStruct(
        id: id,
        expiry: expiry,
        relays: proposal.relays,
        proposer: proposal.proposer,
        requiredNamespaces: proposal.requiredNamespaces,
      ),
    );
    return EngineConnection(
      uri: uri,
      approval: completer.future,
    );
  }

  @override
  Future<PairingStruct> pair(String uri) {
    _isInitialized();
    return client.core.pairing.pair(uri: uri);
  }

  @override
  Future<EngineApproved> approve(SessionApproveParams params) async {
    _isInitialized();
    await _isValidApprove(params);

    final id = params.id;
    final namespaces = params.namespaces;
    final relayProtocol = params.relayProtocol;

    final proposal = client.proposal.get(id.toString());
    final pairingTopic = proposal.pairingTopic;
    final proposer = proposal.proposer;
    final requiredNamespaces = proposal.requiredNamespaces;

    final selfPublicKey = await client.core.crypto.generateKeyPair();
    final peerPublicKey = proposer.publicKey;
    final sessionTopic = await client.core.crypto.generateSharedKey(
      selfPublicKey: selfPublicKey,
      peerPublicKey: peerPublicKey,
    );
    final sessionSettle = SessionSettleParams(
      relay: RelayerProtocolOptions(protocol: relayProtocol ?? "irn"),
      namespaces: namespaces,
      requiredNamespaces: requiredNamespaces,
      controller: SessionPublicKeyMetadata(
          publicKey: selfPublicKey, metadata: client.metadata),
      expiry: calcExpiry(ttl: SESSION_EXPIRY),
    );

    await client.core.relayer.subscribe(topic: sessionTopic);
    final requestId = await _sendRequest<SessionSettleParams>(
      sessionTopic,
      JsonRpcMethod.WC_SESSION_SETTLE,
      sessionSettle,
      (v) => v.toJson(),
    );
    final completer = Completer<SessionStruct>();
    final timer = completer.expirer();
    events.once(engineEvent(EngineEvent.SESSION_APPROVE, requestId), (data) {
      timer.cancel();
      if (data is ErrorResponse) {
        completer.completeError(data);
      } else {
        completer.complete(client.session.get(sessionTopic));
      }
    });

    final session = SessionStruct(
      topic: sessionTopic,
      relay: sessionSettle.relay,
      expiry: sessionSettle.expiry,
      acknowledged: false,
      controller: selfPublicKey,
      namespaces: namespaces,
      requiredNamespaces: requiredNamespaces,
      self: sessionSettle.controller,
      peer: SessionPublicKeyMetadata(
        publicKey: proposer.publicKey,
        metadata: proposer.metadata,
      ),
    );

    await client.session.set(sessionTopic, session);
    await _setExpiry(sessionTopic, calcExpiry(ttl: SESSION_EXPIRY));
    if (pairingTopic != null) {
      await client.core.pairing.updateMetadata(
        topic: pairingTopic,
        metadata: session.peer.metadata,
      );
    }
    if (pairingTopic != null) {
      await _sendResult<ResultSessionPropose>(
        id,
        pairingTopic,
        ResultSessionPropose(
          relay: RelayerProtocolOptions(
            protocol: relayProtocol ?? "irn",
          ),
          responderPublicKey: selfPublicKey,
        ),
        (v) => v.toJson(),
      );
      await client.proposal.delete(
        id.toString(),
        getSdkError(SdkErrorKey.USER_DISCONNECTED),
      );
      await client.core.pairing.activate(topic: pairingTopic);
    }

    // final data = await completer.future;
    return EngineApproved(
      topic: sessionTopic,
      acknowledged: completer.future,
    );
  }

  @override
  Future<void> reject(SessionRejectParams params) async {
    _isInitialized();
    await _isValidReject(params);
    final proposal = client.proposal.get(params.id.toString());
    final pairingTopic = proposal.pairingTopic;
    if (pairingTopic != null) {
      await _sendError(params.id, pairingTopic, params.reason);
      await client.proposal.delete(
        params.id.toString(),
        getSdkError(SdkErrorKey.USER_DISCONNECTED),
      );
    }
  }

  @override
  Future<EngineAcknowledged> update(SessionUpdateParams params) async {
    _isInitialized();
    await _isValidUpdate(params);
    final id = await _sendRequest<RequestSessionUpdate>(
      params.topic,
      JsonRpcMethod.WC_SESSION_UPDATE,
      RequestSessionUpdate(namespaces: params.namespaces),
      (v) => v.toJson(),
    );
    final completer = Completer<void>();
    final timer = completer.expirer();
    events.once(engineEvent(EngineEvent.SESSION_UPDATE, id), (data) {
      timer.cancel();
      if (data is ErrorResponse) {
        completer.completeError(data);
      } else {
        completer.complete();
      }
    });
    await client.session.update(
      params.topic,
      (session) => session.copyWith(namespaces: params.namespaces),
    );

    return EngineAcknowledged(acknowledged: completer.future);
  }

  @override
  Future<EngineAcknowledged> extend(String topic) async {
    _isInitialized();
    await _isValidExtend(topic);
    final id = await _sendRequest<Map<String, dynamic>>(
      topic,
      JsonRpcMethod.WC_SESSION_EXTEND,
      {},
      (v) => v,
    );
    final completer = Completer<void>();
    final timer = completer.expirer();
    events.once(
      engineEvent(EngineEvent.SESSION_EXTEND, id),
      (data) {
        timer.cancel();
        if (data is ErrorResponse) {
          completer.completeError(data);
        } else {
          completer.complete();
        }
      },
    );
    await _setExpiry(topic, calcExpiry(ttl: SESSION_EXPIRY));

    return EngineAcknowledged(acknowledged: completer.future);
  }

  @override
  Future<T> request<T>(SessionRequestParams params) async {
    _isInitialized();
    await _isValidRequest(params);
    final id = await _sendRequest<RequestSessionRequest>(
      params.topic,
      JsonRpcMethod.WC_SESSION_REQUEST,
      RequestSessionRequest(
        request: params.request,
        chainId: params.chainId,
      ),
      (v) => v.toJson(),
    );
    final completer = Completer<T>();
    final timer = completer.expirer();
    events.once(
      engineEvent(EngineEvent.SESSION_REQUEST, id),
      (data) {
        timer.cancel();
        if (data is ErrorResponse) {
          completer.completeError(data);
        } else {
          completer.complete(data as T);
        }
      },
    );
    return completer.future;
  }

  @override
  Future<void> respond(SessionRespondParams params) async {
    _isInitialized();
    await _isValidRespond(params);
    if (isJsonRpcResult(params.response)) {
      await _sendResult<dynamic>(
        params.response.id,
        params.topic,
        (params.response as JsonRpcResult).toJson()['result'],
        (v) => v,
      );
    } else if (isJsonRpcError(params.response)) {
      await _sendError(
        params.response.id,
        params.topic,
        (params.response as JsonRpcError).error,
      );
    }
    _deletePendingSessionRequest(
      params.response.id,
      const ErrorResponse(message: "fulfilled", code: 0),
    );
  }

  @override
  Future<void> ping(String topic) async {
    _isInitialized();
    await _isValidPing(topic);

    if (client.session.keys.contains(topic)) {
      final id = await _sendRequest<Map<String, dynamic>>(
        topic,
        JsonRpcMethod.WC_SESSION_PING,
        {},
        (v) => v,
      );
      final completer = Completer<void>();
      final timer = completer.expirer();
      events.once(
        engineEvent(EngineEvent.SESSION_PING, id),
        (data) {
          timer.cancel();
          if (data is ErrorResponse) {
            completer.completeError(data);
          } else {
            completer.complete();
          }
        },
      );
      await completer.future;
    } else if (client.core.pairing.pairings.keys.contains(topic)) {
      await client.core.pairing.ping(topic: topic);
    }
  }

  @override
  Future<void> emit(SessionEmitParams params) async {
    _isInitialized();
    await _isValidEmit(params);
    await _sendRequest<RequestSessionEvent>(
      params.topic,
      JsonRpcMethod.WC_SESSION_EVENT,
      RequestSessionEvent(
        event: params.event,
        chainId: params.chainId,
      ),
      (v) => v.toJson(),
    );
  }

  @override
  Future<void> disconnect({
    required String topic,
    ErrorResponse? reason,
  }) async {
    _isInitialized();
    await _isValidDisconnect(topic);
    if (client.session.keys.contains(topic)) {
      await _sendRequest<ErrorResponse>(
        topic,
        JsonRpcMethod.WC_SESSION_DELETE,
        reason ?? getSdkError(SdkErrorKey.USER_DISCONNECTED),
        (v) => v.toJson(),
      );
      await _deleteSession(topic);
    } else {
      await client.core.pairing.disconnect(topic: topic);
    }
  }

  @override
  List<SessionStruct> find(params) {
    _isInitialized();
    return client.session
        .getAll()
        .where((session) => isSessionCompatible(session, params))
        .toList();
  }

  @override
  List<PendingRequestStruct> getPendingSessionRequests() {
    _isInitialized();
    return client.pendingRequest.getAll();
  }

  // ---------- Private Helpers --------------------------------------- //

  _deleteSession(
    String topic, {
    bool expirerHasDeleted = false,
  }) async {
    final session = client.session.get(topic);
    // Await the unsubscribe first to avoid deleting the symKey too early below.
    await client.core.relayer.unsubscribe(topic: topic);
    if (!expirerHasDeleted) {
      client.core.expirer.del(topic);
    }
    await Future.wait([
      client.session.delete(topic, getSdkError(SdkErrorKey.USER_DISCONNECTED)),
      client.core.crypto.deleteKeyPair(publicKey: session.self.publicKey),
      client.core.crypto.deleteSymKey(topic: topic),
    ]);
  }

  _deleteProposal(
    String id, {
    bool expirerHasDeleted = false,
  }) async {
    if (!expirerHasDeleted) {
      client.core.expirer.del(id);
    }
    await client.proposal
        .delete(id, getSdkError(SdkErrorKey.USER_DISCONNECTED));
  }

  Future<void> _deletePendingSessionRequest(
    int id,
    ErrorResponse reason, {
    bool expirerHasDeleted = false,
  }) async {
    if (!expirerHasDeleted) {
      client.core.expirer.del(id.toString());
    }

    await client.pendingRequest.delete(id, reason);
  }

  _setExpiry(String topic, int expiry) async {
    if (client.session.keys.contains(topic)) {
      await client.session
          .update(topic, (session) => session.copyWith(expiry: expiry));
    }
    client.core.expirer.set(topic, expiry);
  }

  Future<void> _setProposal(String id, ProposalStruct proposal) async {
    await client.proposal.set(id, proposal);
    client.core.expirer.set(id, proposal.expiry);
  }

  Future<void> setPendingSessionRequest(
    PendingRequestStruct pendingRequest,
  ) async {
    final expiry =
        getEngineRpcOptions(JsonRpcMethod.WC_SESSION_REQUEST).req.ttl;
    await client.pendingRequest.set(pendingRequest.id, pendingRequest);
    if (expiry != null) {
      client.core.expirer.set(pendingRequest.id.toString(), expiry);
    }
  }

  Future<int> _sendRequest<T>(
    String topic,
    JsonRpcMethod method,
    T params,
    Object? Function(T)? paramsToJson,
  ) async {
    final payload = formatJsonRpcRequest<T>(
      method: method.value,
      params: params,
      paramsToJson: paramsToJson,
    );
    final message = await client.core.crypto.encode(
      topic: topic,
      payload: payload.toJson(),
    );
    final opts = getEngineRpcOptions(method).req;
    client.core.history.set(topic: topic, request: payload.toJson());
    client.core.relayer.publish(topic: topic, message: message, opts: opts);
    return payload.id;
  }

  _sendResult<T>(
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
    final message = await client.core.crypto.encode(
      topic: topic,
      payload: payload.toJson(),
    );
    final record = client.core.history.get(topic: topic, id: id);
    final opts =
        getEngineRpcOptions((record.request['method'] as String).jsonRpcMethod!)
            .res;
    // await is intentionally omitted to speed up performance
    client.core.relayer.publish(topic: topic, message: message, opts: opts);
    client.core.history.resolve(payload.toJson());
  }

  _sendError(int id, String topic, dynamic error) async {
    final payload = formatJsonRpcError(id: id, error: error);
    final message = await client.core.crypto.encode(
      topic: topic,
      payload: payload.toJson(),
    );
    final record = client.core.history.get(topic: topic, id: id);
    final opts =
        getEngineRpcOptions((record.request['method'] as String).jsonRpcMethod!)
            .res;
    // await is intentionally omitted to speed up performance
    client.core.relayer.publish(topic: topic, message: message, opts: opts);
    client.core.history.resolve(payload.toJson());
  }

  _cleanup() async {
    final List<String> sessionTopics = [];
    final List<int> proposalIds = [];
    client.session.getAll().forEach((session) {
      if (isExpired(session.expiry)) sessionTopics.add(session.topic);
    });
    client.proposal.getAll().forEach((proposal) {
      if (isExpired(proposal.expiry)) proposalIds.add(proposal.id);
    });
    await Future.wait([
      ...sessionTopics.map((topic) => _deleteSession(topic)),
      ...proposalIds.map((id) => _deleteProposal(id.toString())),
    ]);
  }

  void _isInitialized() {
    if (!_initialized) {
      final error =
          getInternalError(InternalErrorKey.NOT_INITIALIZED, context: name);
      throw WCException(error.message);
    }
  }

  // ---------- Relay Events Router ----------------------------------- //

  _registerRelayerEvents() {
    client.core.relayer.on(RelayerEvents.message, (data) async {
      if (data is RelayerMessageEvent) {
        final topic = data.topic;
        final message = data.message;

        // messages of certain types should be ignored as they are handled by their respective SDKs
        if (_ignoredPayloadTypes
            .contains(client.core.crypto.getPayloadType(message))) {
          return;
        }

        final payload =
            await client.core.crypto.decode(topic: topic, encoded: message);
        if (isJsonRpcRequest(payload)) {
          client.core.history.set(topic: topic, request: payload);
          _onRelayEventRequest(topic, payload);
        } else if (isJsonRpcResponse(payload)) {
          client.core.history.resolve(payload);
          _onRelayEventResponse(topic, payload);
        }
      }
    });
  }

  Future<void> _onRelayEventRequest(
    String topic,
    Map<String, dynamic> payload,
  ) async {
    final reqMethod = (payload['method'] as String).jsonRpcMethod;

    switch (reqMethod) {
      case JsonRpcMethod.WC_SESSION_PROPOSE:
        return _onSessionProposeRequest(topic, payload);
      case JsonRpcMethod.WC_SESSION_SETTLE:
        return _onSessionSettleRequest(topic, payload);
      case JsonRpcMethod.WC_SESSION_REQUEST:
        return _onSessionRequest(topic, payload);
      case JsonRpcMethod.WC_SESSION_DELETE:
        return _onSessionDeleteRequest(topic, payload);
      case JsonRpcMethod.WC_SESSION_PING:
        return _onSessionPingRequest(topic, payload);
      case JsonRpcMethod.WC_SESSION_EVENT:
        return _onSessionEventRequest(topic, payload);
      case JsonRpcMethod.WC_SESSION_UPDATE:
        return _onSessionUpdateRequest(topic, payload);
      case JsonRpcMethod.WC_SESSION_EXTEND:
        return _onSessionExtendRequest(topic, payload);
      default:
        return client.logger.i('Unsupported request method $reqMethod');
    }
  }

  Future<void> _onRelayEventResponse(
    String topic,
    Map<String, dynamic> payload,
  ) async {
    final int id = payload['id'];
    final record = client.core.history.get(topic: topic, id: id);
    final resMethod = (record.request['method'] as String).jsonRpcMethod;

    switch (resMethod) {
      case JsonRpcMethod.WC_SESSION_PROPOSE:
        return _onSessionProposeResponse(topic, payload);
      case JsonRpcMethod.WC_SESSION_SETTLE:
        return _onSessionSettleResponse(topic, payload);
      case JsonRpcMethod.WC_SESSION_UPDATE:
        return _onSessionUpdateResponse(topic, payload);
      case JsonRpcMethod.WC_SESSION_EXTEND:
        return _onSessionExtendResponse(topic, payload);
      case JsonRpcMethod.WC_SESSION_PING:
        return _onSessionPingResponse(topic, payload);
      case JsonRpcMethod.WC_SESSION_REQUEST:
        return _onSessionRequestResponse(topic, payload);
      default:
        return client.logger.i('Unsupported response method $resMethod');
    }
  }

  // ---------- Relay Events Handlers --------------------------------- //

  Future<void> _onSessionProposeRequest(
    String topic,
    Map<String, dynamic> payload,
  ) async {
    final int id = payload['id'];
    try {
      final request = JsonRpcRequest<RequestSessionPropose>.fromJson(
        payload,
        (json) => RequestSessionPropose.fromJson(json as Map<String, dynamic>),
      );
      _isValidConnect(SessionConnectParams(
        requiredNamespaces: request.params!.requiredNamespaces,
        relays: request.params!.relays,
      ));
      final expiry = calcExpiry(ttl: FIVE_MINUTES);
      final proposal = ProposalStruct(
        id: request.id,
        expiry: expiry,
        relays: request.params!.relays,
        proposer: request.params!.proposer,
        requiredNamespaces: request.params!.requiredNamespaces,
        pairingTopic: topic,
      );
      await _setProposal(request.id.toString(), proposal);
      client.events.emit(
        SignClientEvent.SESSION_PROPOSAL.value,
        SignClientEventParams<RequestSessionPropose>(
          id: id,
          params: request.params!,
        ),
      );
    } catch (err) {
      await _sendError(id, topic, err);
      client.logger.e(err);
    }
  }

  Future<void> _onSessionProposeResponse(
    String topic,
    Map<String, dynamic> payload,
  ) async {
    final int id = payload['id'];
    if (isJsonRpcResult(payload)) {
      final result = ResultSessionPropose.fromJson(
          payload['result'] as Map<String, dynamic>);
      client.logger.i({
        'type': "method",
        'method': "onSessionProposeResponse",
        'result': result.toJson(),
      });
      final proposal = client.proposal.get(id.toString());
      client.logger.i({
        'type': "method",
        'method': "onSessionProposeResponse",
        'proposal': proposal.toJson(),
      });
      final selfPublicKey = proposal.proposer.publicKey;
      client.logger.i({
        'type': "method",
        'method': "onSessionProposeResponse",
        'selfPublicKey': selfPublicKey,
      });
      final peerPublicKey = result.responderPublicKey;
      client.logger.i({
        'type': "method",
        'method': "onSessionProposeResponse",
        'peerPublicKey': peerPublicKey,
      });
      final sessionTopic = await client.core.crypto.generateSharedKey(
        selfPublicKey: selfPublicKey,
        peerPublicKey: peerPublicKey,
      );
      client.logger.i({
        'type': "method",
        'method': "onSessionProposeResponse",
        'sessionTopic': sessionTopic,
      });
      final subscriptionId =
          await client.core.relayer.subscribe(topic: sessionTopic);
      client.logger.i({
        'type': "method",
        'method': "onSessionProposeResponse",
        'subscriptionId': subscriptionId,
      });
      await client.core.pairing.activate(topic: topic);
    } else if (isJsonRpcError(payload)) {
      await client.proposal.delete(
        id.toString(),
        getSdkError(SdkErrorKey.USER_DISCONNECTED),
      );
      final errorPayload = JsonRpcError.fromJson(payload);
      events.emit(
        engineEvent(EngineEvent.SESSION_CONNECT),
        errorPayload.error,
      );
    }
  }

  Future<void> _onSessionSettleRequest(
    String topic,
    Map<String, dynamic> payload,
  ) async {
    final int id = payload['id'];
    try {
      final request = JsonRpcRequest.fromJson(
        payload,
        (json) =>
            SessionSettleRequestParams.fromJson(json as Map<String, dynamic>),
      );
      _isValidSessionSettleRequest(request.params!);
      final session = SessionStruct(
        topic: topic,
        relay: request.params!.relay,
        expiry: request.params!.expiry,
        namespaces: request.params!.namespaces,
        acknowledged: true,
        controller: request.params!.controller.publicKey,
        self: SessionPublicKeyMetadata(
          publicKey: "",
          metadata: client.metadata,
        ),
        peer: SessionPublicKeyMetadata(
          publicKey: request.params!.controller.publicKey,
          metadata: request.params!.controller.metadata,
        ),
      );
      await _sendResult<ResultSessionSettle>(id, topic, true, (v) => v);
      events.emit(
        engineEvent(EngineEvent.SESSION_CONNECT),
        session,
      );
    } catch (err) {
      await _sendError(id, topic, err);
      client.logger.e(err);
    }
  }

  Future<void> _onSessionSettleResponse(
    String topic,
    Map<String, dynamic> payload,
  ) async {
    final int id = payload['id'];
    if (isJsonRpcResult(payload)) {
      await client.session.update(
        topic,
        (session) => session.copyWith(acknowledged: true),
      );
      events.emit(engineEvent(EngineEvent.SESSION_APPROVE, id));
    } else if (isJsonRpcError(payload)) {
      await client.session.delete(
        topic,
        getSdkError(SdkErrorKey.USER_DISCONNECTED),
      );
      events.emit(
        engineEvent(EngineEvent.SESSION_APPROVE, id),
        JsonRpcError.fromJson(payload).error,
      );
    }
  }

  Future<void> _onSessionUpdateRequest(
    String topic,
    Map<String, dynamic> payload,
  ) async {
    final int id = payload['id'];
    final params = RequestSessionUpdate.fromJson(payload['params']);

    try {
      _isValidUpdate(SessionUpdateParams(
        topic: topic,
        namespaces: params.namespaces,
      ));
      await client.session.update(
        topic,
        (session) => session.copyWith(namespaces: params.namespaces),
      );
      await _sendResult(id, topic, true, (v) => v);
      client.events.emit("session_update", {
        'id': id,
        'topic': topic,
        'params': params.toJson(),
      });
    } catch (err) {
      await _sendError(id, topic, err);
      client.logger.e(err);
    }
  }

  void _onSessionUpdateResponse(
    String topic,
    Map<String, dynamic> payload,
  ) {
    final int id = payload['id'];
    if (isJsonRpcResult(payload)) {
      events.emit(engineEvent(EngineEvent.SESSION_UPDATE, id));
    } else if (isJsonRpcError(payload)) {
      events.emit(
        engineEvent(EngineEvent.SESSION_UPDATE, id),
        JsonRpcError.fromJson(payload).error,
      );
    }
  }

  Future<void> _onSessionExtendRequest(
    String topic,
    Map<String, dynamic> payload,
  ) async {
    final int id = payload['id'];
    try {
      _isValidExtend(topic);
      await _setExpiry(topic, calcExpiry(ttl: SESSION_EXPIRY));
      await _sendResult(id, topic, true, (v) => v);
      client.events.emit(
        SignClientEvent.SESSION_EXTEND.value,
        SignClientEventParams<void>(
          id: id,
          topic: topic,
        ),
      );
    } catch (err) {
      await _sendError(id, topic, err);
      client.logger.e(err);
    }
  }

  void _onSessionExtendResponse(
    String topic,
    Map<String, dynamic> payload,
  ) {
    final int id = payload['id'];
    if (isJsonRpcResult(payload)) {
      events.emit(engineEvent(EngineEvent.SESSION_EXTEND, id));
    } else if (isJsonRpcError(payload)) {
      events.emit(
        engineEvent(EngineEvent.SESSION_EXTEND, id),
        JsonRpcError.fromJson(payload).error,
      );
    }
  }

  Future<void> _onSessionPingRequest(
    String topic,
    Map<String, dynamic> payload,
  ) async {
    final int id = payload['id'];
    try {
      _isValidPing(topic);
      await _sendResult<bool>(id, topic, true, (v) => v);
      client.events.emit(
        SignClientEvent.SESSION_PING.value,
        SignClientEventParams<void>(
          id: id,
          topic: topic,
        ),
      );
    } catch (err) {
      await _sendError(id, topic, err);
      client.logger.e(err);
    }
  }

  void _onSessionPingResponse(
    String topic,
    Map<String, dynamic> payload,
  ) {
    final int id = payload['id'];
    // put at the end of the stack to avoid a race condition
    // where session_ping listener is not yet _initialized
    Timer(const Duration(milliseconds: 500), () {
      if (isJsonRpcResult(payload)) {
        events.emit(engineEvent(EngineEvent.SESSION_PING, id));
      } else if (isJsonRpcError(payload)) {
        events.emit(
          engineEvent(EngineEvent.SESSION_PING, id),
          JsonRpcError.fromJson(payload).error,
        );
      }
    });
  }

  Future<void> _onSessionDeleteRequest(
    String topic,
    Map<String, dynamic> payload,
  ) async {
    final int id = payload['id'];

    try {
      _isValidDisconnect(topic);
      // RPC request needs to happen before deletion as it utalises session encryption
      await _sendResult<bool>(id, topic, true, (v) => v);
      await _deleteSession(topic);
      client.events.emit(
          SignClientEvent.SESSION_DELETE.value,
          SignClientEventParams<void>(
            id: id,
            topic: topic,
          ));
    } catch (err) {
      await _sendError(id, topic, err);
      client.logger.e(err);
    }
  }

  Future<void> _onSessionRequest(
    String topic,
    Map<String, dynamic> payload,
  ) async {
    final int id = payload['id'];

    try {
      final params = RequestSessionRequest.fromJson(payload['params']);
      _isValidRequest(SessionRequestParams(
        topic: topic,
        request: params.request,
        chainId: params.chainId,
      ));
      await setPendingSessionRequest(PendingRequestStruct(topic, id, params));
      client.events.emit(
        SignClientEvent.SESSION_REQUEST.value,
        SignClientEventParams<RequestSessionRequest>(
          id: id,
          topic: topic,
          params: params,
        ),
      );
    } catch (err) {
      await _sendError(id, topic, err);
      client.logger.e(err);
    }
  }

  void _onSessionRequestResponse(
    String topic,
    Map<String, dynamic> payload,
  ) {
    final int id = payload['id'];
    if (isJsonRpcResult(payload)) {
      events.emit(
        engineEvent(EngineEvent.SESSION_REQUEST, id),
        payload['result'],
      );
    } else if (isJsonRpcError(payload)) {
      events.emit(
        engineEvent(EngineEvent.SESSION_REQUEST, id),
        JsonRpcError.fromJson(payload).error,
      );
    }
  }

  Future<void> _onSessionEventRequest(
    String topic,
    Map<String, dynamic> payload,
  ) async {
    final int id = payload['id'];
    final params = RequestSessionEvent.fromJson(payload['params']);
    try {
      _isValidEmit(SessionEmitParams(
        topic: topic,
        event: params.event,
        chainId: params.chainId,
      ));
      client.events.emit(
          SignClientEvent.SESSION_REQUEST.value,
          SignClientEventParams<RequestSessionEvent>(
            id: id,
            topic: topic,
            params: params,
          ));
    } catch (err) {
      await _sendError(id, topic, err);
      client.logger.e(err);
    }
  }

  // ---------- Expirer Events ---------------------------------------- //

  _registerExpirerEvents() {
    client.core.expirer.on(ExpirerEvents.expired, (data) async {
      if (data is ExpirerEvent) {
        final expirerTarget = parseExpirerTarget(data.target);
        final id = expirerTarget.id;
        final topic = expirerTarget.topic;

        if (id != null &&
            getPendingSessionRequests()
                .where((element) => element.id == id)
                .isNotEmpty) {
          return await _deletePendingSessionRequest(
            id,
            getInternalError(InternalErrorKey.EXPIRED),
            expirerHasDeleted: true,
          );
        }

        if (topic != null) {
          if (client.session.keys.contains(topic)) {
            await _deleteSession(topic, expirerHasDeleted: true);
            client.events.emit(
              SignClientEvent.SESSION_EXPIRE.value,
              SignClientEventParams<void>(topic: topic),
            );
          }
        } else if (id != null) {
          await _deleteProposal(id.toString(), expirerHasDeleted: true);
        }
      }
    });
  }

  // ---------- Validation Helpers ------------------------------------ //
  Future<void> _isValidPairingTopic(String topic) async {
    if (!client.core.pairing.pairings.keys.contains(topic)) {
      final error = getInternalError(
        InternalErrorKey.NO_MATCHING_KEY,
        context: 'pairing topic doesn\'t exist: $topic',
      );
      throw WCException(error.message);
    }
    if (isExpired(client.core.pairing.pairings.get(topic).expiry)) {
      // await deletePairing(topic);
      final error = getInternalError(
        InternalErrorKey.EXPIRED,
        context: 'pairing topic: $topic',
      );
      throw WCException(error.message);
    }
  }

  Future<void> _isValidSessionTopic(String topic) async {
    if (!client.session.keys.contains(topic)) {
      final error = getInternalError(
        InternalErrorKey.NO_MATCHING_KEY,
        context: 'session topic doesn\'t exist: $topic',
      );
      throw WCException(error.message);
    }
    if (isExpired(client.session.get(topic).expiry)) {
      await _deleteSession(topic);
      final error = getInternalError(
        InternalErrorKey.EXPIRED,
        context: 'session topic: $topic',
      );
      throw WCException(error.message);
    }
  }

  Future<void> _isValidSessionOrPairingTopic(String topic) async {
    if (client.session.keys.contains(topic)) {
      await _isValidSessionTopic(topic);
    } else if (client.core.pairing.pairings.keys.contains(topic)) {
      _isValidPairingTopic(topic);
    } else {
      final error = getInternalError(
        InternalErrorKey.NO_MATCHING_KEY,
        context: 'session or pairing topic doesn\'t exist: $topic',
      );
      throw WCException(error.message);
    }
  }

  Future<void> _isValidProposalId(int id) async {
    if (!client.proposal.keys.contains(id.toString())) {
      final error = getInternalError(
        InternalErrorKey.NO_MATCHING_KEY,
        context: 'proposal id doesn\'t exist: $id',
      );
      throw WCException(error.message);
    }
    if (isExpired(client.proposal.get(id.toString()).expiry)) {
      await _deleteProposal(id.toString());
      final error = getInternalError(
        InternalErrorKey.EXPIRED,
        context: 'proposal id: $id',
      );
      throw WCException(error.message);
    }
  }

  // ---------- Validation  ------------------------------------------- //

  Future<void> _isValidConnect(SessionConnectParams params) async {
    final requiredNamespaces = params.requiredNamespaces;
    final pairingTopic = params.pairingTopic;
    final relays = params.relays;

    if (pairingTopic != null) {
      await _isValidPairingTopic(pairingTopic);
    }
    final validRequiredNamespacesError =
        isValidRequiredNamespaces(requiredNamespaces, "connect()");
    if (validRequiredNamespacesError != null) {
      throw WCException(validRequiredNamespacesError.message);
    }
    if (!isValidRelays(relays, true)) {
      final error = getInternalError(InternalErrorKey.MISSING_OR_INVALID,
          context: 'connect() relays: $relays');
      throw WCException(error.message);
    }
  }

  Future<void> _isValidApprove(SessionApproveParams params) async {
    final id = params.id;
    final namespaces = params.namespaces;

    await _isValidProposalId(id);
    final proposal = client.proposal.get(id.toString());
    final validNamespacesError = isValidNamespaces(namespaces, "approve()");
    if (validNamespacesError != null) {
      throw WCException(validNamespacesError.message);
    }
  }

  Future<void> _isValidReject(SessionRejectParams params) async {
    await _isValidProposalId(params.id);
    if (!isValidErrorReason(params.reason)) {
      final error = getInternalError(
        InternalErrorKey.MISSING_OR_INVALID,
        context: 'reject() reason: ${params.reason.toJson()}',
      );
      throw WCException(error.message);
    }
  }

  void _isValidSessionSettleRequest(SessionSettleRequestParams params) {
    if (!isValidRelay(params.relay)) {
      final error = getInternalError(
        InternalErrorKey.MISSING_OR_INVALID,
        context: '_onSessionSettleRequest() relay protocol should be a string',
      );
      throw WCException(error.message);
    }
    final validControllerError =
        isValidController(params.controller, "_onSessionSettleRequest()");
    if (validControllerError != null) {
      throw WCException(validControllerError.message);
    }
    final validNamespacesError =
        isValidNamespaces(params.namespaces, "_onSessionSettleRequest()");
    if (validNamespacesError != null) {
      throw WCException(validNamespacesError.message);
    }
    if (isExpired(params.expiry)) {
      final error = getInternalError(InternalErrorKey.EXPIRED,
          context: '_onSessionSettleRequest()');
      throw WCException(error.message);
    }
  }

  Future<void> _isValidUpdate(SessionUpdateParams params) async {
    await _isValidSessionTopic(params.topic);
    final session = client.session.get(params.topic);
    final validNamespacesError =
        isValidNamespaces(params.namespaces, "update()");
    if (validNamespacesError != null) {
      throw WCException(validNamespacesError.message);
    }
    final conformingNamespacesError = isConformingNamespaces(
      session.requiredNamespaces!,
      params.namespaces,
      "update()",
    );
    if (conformingNamespacesError != null) {
      throw WCException(conformingNamespacesError.message);
    }
  }

  Future<void> _isValidExtend(String topic) async {
    await _isValidSessionTopic(topic);
  }

  Future<void> _isValidRequest(SessionRequestParams params) async {
    final topic = params.topic;
    final request = params.request;
    final chainId = params.chainId;

    await _isValidSessionTopic(topic);
    final session = client.session.get(topic);
    final namespaces = session.namespaces;

    if (!isValidNamespacesChainId(namespaces, chainId)) {
      final error = getInternalError(
        InternalErrorKey.MISSING_OR_INVALID,
        context: 'request() chainId: $chainId',
      );
      throw WCException(error.message);
    }

    if (!isValidNamespacesRequest(namespaces, chainId, request.method)) {
      final error = getInternalError(
        InternalErrorKey.MISSING_OR_INVALID,
        context: 'request() method: ${request.method}',
      );
      throw WCException(error.message);
    }
  }

  Future<void> _isValidRespond(SessionRespondParams params) async {
    await _isValidSessionTopic(params.topic);
  }

  Future<void> _isValidPing(String topic) async {
    await _isValidSessionOrPairingTopic(topic);
  }

  Future<void> _isValidEmit(SessionEmitParams params) async {
    await _isValidSessionTopic(params.topic);
    final session = client.session.get(params.topic);
    final namespaces = session.namespaces;
    final event = params.event;
    if (!isValidNamespacesChainId(namespaces, params.chainId)) {
      final error = getInternalError(InternalErrorKey.MISSING_OR_INVALID,
          context: 'emit() chainId: ${params.chainId}');
      throw WCException(error.message);
    }
    if (!isValidNamespacesEvent(namespaces, params.chainId, event.name)) {
      final error = getInternalError(
        InternalErrorKey.MISSING_OR_INVALID,
        context: 'emit() event: $event',
      );
      throw WCException(error.message);
    }
  }

  Future<void> _isValidDisconnect(String topic) async {
    await _isValidSessionOrPairingTopic(topic);
  }
}
