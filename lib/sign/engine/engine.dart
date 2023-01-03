import 'dart:async';

import 'package:wallet_connect/core/expirer/constants.dart';
import 'package:wallet_connect/core/expirer/types.dart';
import 'package:wallet_connect/core/pairing/types.dart';
import 'package:wallet_connect/core/relayer/constants.dart';
import 'package:wallet_connect/core/relayer/types.dart';
import 'package:wallet_connect/sign/engine/constants.dart';
import 'package:wallet_connect/sign/engine/types.dart';
import 'package:wallet_connect/sign/sign-client/client/types.dart';
import 'package:wallet_connect/sign/sign-client/jsonrpc/types.dart';
import 'package:wallet_connect/sign/sign-client/pendingRequest/types.dart';
import 'package:wallet_connect/sign/sign-client/proposal/types.dart';
import 'package:wallet_connect/sign/sign-client/session/constants.dart';
import 'package:wallet_connect/sign/sign-client/session/types.dart';
import 'package:wallet_connect/utils/crypto.dart';
import 'package:wallet_connect/utils/error.dart';
import 'package:wallet_connect/utils/misc.dart';
import 'package:wallet_connect/utils/timeout_completer.dart';
import 'package:wallet_connect/utils/validator.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/types.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/error.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/format.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/validator.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';

class Engine with IEvents implements IEngine {
  final String name = ENGINE_CONTEXT;

  @override
  final EventSubject events;

  bool _initialized = false;
  List<int> ignoredPayloadTypes = [TYPE_1];

  @override
  final ISignClient client;

  Engine({required this.client}) : events = EventSubject();

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
  Future<EngineTypesConnection> connect(SessionConnectParams params) async {
    _isInitialized();
    await _isValidConnect(params);

    var topic = params.pairingTopic;
    var uri;
    var active = false;

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

    final proposal = ProposalTypesRequestStruct(
      requiredNamespaces: params.requiredNamespaces,
      relays: params.relays ??
          [RelayerTypesProtocolOptions(protocol: RELAYER_DEFAULT_PROTOCOL)],
      proposer: ProposalTypesProposer(
        publicKey: publicKey,
        metadata: client.metadata,
      ),
    );

    final completer = Completer<SessionTypesStruct>();
    events.once(
      engineEvent(EngineTypesEvent.SESSION_CONNECT),
      null,
      (event, _) async {
        if (event.eventData is ErrorResponse) {
          completer.completeError(event.eventData.toString());
        } else if (event.eventData is SessionTypesStruct) {
          final session = event.eventData as SessionTypesStruct;
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

    if (topic == null) {
      final error = getInternalError(InternalErrorKey.NO_MATCHING_KEY,
          context: 'connect() pairing topic: ${topic}');
      throw WCException(error.message);
    }

    final id = await _sendRequest<ProposalTypesRequestStruct>(
      topic,
      JsonRpcMethod.WC_SESSION_PROPOSE,
      proposal,
      (v) => v.toJson(),
    );

    final expiry = calcExpiry(ttl: FIVE_MINUTES);
    await _setProposal(
      id.toString(),
      ProposalTypesStruct(
        id: id,
        expiry: expiry,
        relays: proposal.relays,
        proposer: proposal.proposer,
        requiredNamespaces: proposal.requiredNamespaces,
      ),
    );
    return EngineTypesConnection(
      uri: uri,
      approval: await completer.future,
    );
  }

  @override
  Future<PairingTypesStruct> pair(String uri) {
    _isInitialized();
    return client.core.pairing.pair(uri: uri);
  }

  @override
  Future<EngineTypesApproved> approve(SessionApproveParams params) async {
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
      relay: RelayerTypesProtocolOptions(protocol: relayProtocol ?? "irn"),
      namespaces: namespaces,
      requiredNamespaces: requiredNamespaces,
      controller: SessionTypesPublicKeyMetadata(
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
    final completer = Completer<SessionTypesStruct>();
    final timer = completer.expirer();
    events.once(engineEvent(EngineTypesEvent.SESSION_APPROVE, requestId), null,
        (event, _) {
      timer.cancel();
      if (event.eventData is ErrorResponse) {
        completer.completeError(event.eventData as ErrorResponse);
      } else {
        completer.complete(client.session.get(sessionTopic));
      }
    });

    final session = SessionTypesStruct(
      topic: sessionTopic,
      relay: sessionSettle.relay,
      expiry: sessionSettle.expiry,
      acknowledged: false,
      controller: selfPublicKey,
      namespaces: namespaces,
      requiredNamespaces: requiredNamespaces,
      self: sessionSettle.controller,
      peer: SessionTypesPublicKeyMetadata(
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
    if (pairingTopic != null && id != null) {
      await _sendResult<ResultSessionPropose>(
        id,
        pairingTopic,
        ResultSessionPropose(
          relay: RelayerTypesProtocolOptions(
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

    return EngineTypesApproved(
      topic: sessionTopic,
      acknowledged: (await completer.future).acknowledged,
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
  Future<bool> update(SessionUpdateParams params) async {
    _isInitialized();
    await _isValidUpdate(params);
    final id = await _sendRequest<RpcSessionUpdateParams>(
      params.topic,
      JsonRpcMethod.WC_SESSION_UPDATE,
      RpcSessionUpdateParams(namespaces: params.namespaces),
      (v) => v.toJson(),
    );
    final completer = Completer<void>();
    final timer = completer.expirer();
    events.once(engineEvent(EngineTypesEvent.SESSION_UPDATE, id), null,
        (event, _) {
      timer.cancel();
      if (event.eventData is ErrorResponse) {
        completer.completeError(event.eventData as ErrorResponse);
      } else {
        completer.complete();
      }
    });
    await client.session.update(
      params.topic,
      (session) => session.copyWith(namespaces: params.namespaces),
    );

    await completer.future;
    return completer.isCompleted;
  }

  @override
  Future<bool> extend(String topic) async {
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
      engineEvent(EngineTypesEvent.SESSION_EXTEND, id),
      null,
      (event, _) {
        timer.cancel();
        if (event.eventData is ErrorResponse) {
          completer.completeError(event.eventData as ErrorResponse);
        } else {
          completer.complete();
        }
      },
    );
    await _setExpiry(topic, calcExpiry(ttl: SESSION_EXPIRY));

    await completer.future;
    return completer.isCompleted;
  }

  @override
  Future<T> request<T>(SessionRequestParams params) async {
    _isInitialized();
    await _isValidRequest(params);
    final id = await _sendRequest<RpcSessionRequestParams>(
      params.topic,
      JsonRpcMethod.WC_SESSION_REQUEST,
      RpcSessionRequestParams(
        request: params.request,
        chainId: params.chainId,
      ),
      (v) => v.toJson(),
    );
    final completer = Completer<T>();
    final timer = completer.expirer();
    events.once(
      engineEvent(EngineTypesEvent.SESSION_REQUEST, id),
      null,
      (event, _) {
        timer.cancel();
        if (event.eventData is ErrorResponse) {
          completer.completeError(event.eventData as ErrorResponse);
        } else {
          completer.complete(event.eventData as T);
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
        engineEvent(EngineTypesEvent.SESSION_PING, id),
        null,
        (event, _) {
          timer.cancel();
          if (event.eventData is ErrorResponse) {
            completer.completeError(event.eventData as ErrorResponse);
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
    await _sendRequest<RpcSessionEventParams>(
      params.topic,
      JsonRpcMethod.WC_SESSION_EVENT,
      RpcSessionEventParams(
        event: params.event,
        chainId: params.chainId,
      ),
      (v) => v.toJson(),
    );
  }

  @override
  Future<void> disconnect(String topic) async {
    _isInitialized();
    await _isValidDisconnect(topic);
    if (client.session.keys.contains(topic)) {
      await _sendRequest<ErrorResponse>(
        topic,
        JsonRpcMethod.WC_SESSION_DELETE,
        getSdkError(SdkErrorKey.USER_DISCONNECTED),
        (v) => v.toJson(),
      );
      await _deleteSession(topic);
    } else {
      await client.core.pairing.disconnect(topic: topic);
    }
  }

  @override
  List<SessionTypesStruct> find(params) {
    _isInitialized();
    return client.session
        .getAll()
        .where((session) => isSessionCompatible(session, params))
        .toList();
  }

  @override
  List<PendingRequestTypesStruct> getPendingSessionRequests() {
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
      // client.session.delete(topic, getSdkError(SdkErrorKey.USER_DISCONNECTED)),
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

  _setProposal(String id, ProposalTypesStruct proposal) async {
    await client.proposal.set(id, proposal);
    client.core.expirer.set(id, proposal.expiry);
  }

  setPendingSessionRequest(
    PendingRequestTypesStruct pendingRequest,
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
        getEngineRpcOptions((record.request['method'] as String).jsonRpcMethod)
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
        getEngineRpcOptions((record.request['method'] as String).jsonRpcMethod)
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
    client.core.relayer.on(RelayerEvents.message, (event) async {
      if (event.eventData is RelayerTypesMessageEvent) {
        final topic = (event.eventData as RelayerTypesMessageEvent).topic;
        final message = (event.eventData as RelayerTypesMessageEvent).message;

        // messages of certain types should be ignored as they are handled by their respective SDKs
        if (ignoredPayloadTypes
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
    JsonRpcRequest payload,
  ) async {
    final reqMethod = payload.method.jsonRpcMethod;

    switch (reqMethod) {
      case JsonRpcMethod.WC_SESSION_PROPOSE:
        return _onSessionProposeRequest(topic, payload);
      case JsonRpcMethod.WC_SESSION_SETTLE:
        return _onSessionSettleRequest(topic, payload);
      case JsonRpcMethod.WC_SESSION_REQUEST:
      // return onSessionUpdateRequest(topic, payload);
      case JsonRpcMethod.WC_SESSION_DELETE:
      // return onSessionExtendRequest(topic, payload);
      case JsonRpcMethod.WC_SESSION_PING:
      // return onSessionPingRequest(topic, payload);
      case JsonRpcMethod.WC_SESSION_EVENT:
      // return onSessionDeleteRequest(topic, payload);
      case JsonRpcMethod.WC_SESSION_UPDATE:
      // return onSessionRequest(topic, payload);
      case JsonRpcMethod.WC_SESSION_EXTEND:
      // return onSessionEventRequest(topic, payload);
      default:
        return client.logger.i('Unsupported request method $reqMethod');
    }
  }

  Future<void> _onRelayEventResponse(
    String topic,
    JsonRpcResponse payload,
  ) async {
    final record = await client.core.history.get(topic: topic, id: payload.id);
    final resMethod = (record.request['method'] as String).jsonRpcMethod;

    switch (resMethod) {
      case JsonRpcMethod.WC_SESSION_PROPOSE:
        return _onSessionProposeResponse(topic, payload);
      case JsonRpcMethod.WC_SESSION_SETTLE:
        return _onSessionSettleResponse(topic, payload);
      case JsonRpcMethod.WC_SESSION_UPDATE:
      // return onSessionUpdateResponse(topic, payload);
      case JsonRpcMethod.WC_SESSION_EXTEND:
      // return onSessionExtendResponse(topic, payload);
      case JsonRpcMethod.WC_SESSION_PING:
      // return onSessionPingResponse(topic, payload);
      case JsonRpcMethod.WC_SESSION_REQUEST:
      // return onSessionRequestResponse(topic, payload);
      default:
        return client.logger.i('Unsupported response method $resMethod');
    }
  }

  // ---------- Relay Events Handlers --------------------------------- //

  Future<void> _onSessionProposeRequest(
    String topic,
    JsonRpcRequest payload,
  ) async {
    try {
      _isValidConnect(payload.params);
      final expiry = calcExpiry(ttl: FIVE_MINUTES);
      final proposal = ProposalTypesStruct(
        id: payload.id,
        expiry: expiry,
        relays: payload.params.relays,
        proposer: payload.params.proposer,
        requiredNamespaces: payload.params.requiredNamespaces,
        pairingTopic: topic,
      );
      await _setProposal(payload.id.toString(), proposal);
      client.events.emitData(
        SignClientTypesEvent.SESSION_PROPOSAL.value,
        {'id': payload.id, 'params': proposal.toJson()},
      );
    } catch (err) {
      await _sendError(payload.id, topic, err);
      client.logger.e(err);
    }
  }

  Future<void> _onSessionProposeResponse(
    String topic,
    JsonRpcResponse payload,
  ) async {
    final id = payload.id;
    if (isJsonRpcResult(payload)) {
      final result = ResultSessionPropose.fromJson(
          (payload as JsonRpcResult).result as Map<String, dynamic>);
      client.logger.i({
        'type': "method",
        'method': "onSessionProposeResponse",
        'result': result
      });
      final proposal = client.proposal.get(id.toString());
      client.logger.i({
        'type': "method",
        'method': "onSessionProposeResponse",
        'proposal': proposal
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
      events.emitData(
        engineEvent(EngineTypesEvent.SESSION_CONNECT),
        (payload as JsonRpcError).error,
      );
    }
  }

  Future<void> _onSessionSettleRequest(
    String topic,
    JsonRpcRequest payload,
  ) async {
    try {
      _isValidSessionSettleRequest(payload.params);
      final session = SessionTypesStruct(
        topic: topic,
        relay: payload.params.relay,
        expiry: payload.params.expiry,
        namespaces: payload.params.namespaces,
        acknowledged: true,
        controller: payload.params.controller.publicKey,
        self: SessionTypesPublicKeyMetadata(
          publicKey: "",
          metadata: client.metadata,
        ),
        peer: SessionTypesPublicKeyMetadata(
          publicKey: payload.params.controller.publicKey,
          metadata: payload.params.controller.metadata,
        ),
        requiredNamespaces: null,
      );
      await _sendResult<ResultSessionSettle>(payload.id, topic, true, (v) => v);
      events.emitData(engineEvent(EngineTypesEvent.SESSION_CONNECT), session);
    } catch (err) {
      await _sendError(payload.id, topic, err);
      client.logger.e(err);
    }
  }

  Future<void> _onSessionSettleResponse(
    String topic,
    JsonRpcResponse payload,
  ) async {
    if (isJsonRpcResult(payload)) {
      await client.session.update(
        topic,
        (session) => session.copyWith(acknowledged: true),
      );
      events.emitData(
          engineEvent(EngineTypesEvent.SESSION_APPROVE, payload.id), {});
    } else if (isJsonRpcError(payload)) {
      await client.session
          .delete(topic, getSdkError(SdkErrorKey.USER_DISCONNECTED));
      events.emitData(
        engineEvent(EngineTypesEvent.SESSION_APPROVE, payload.id),
        (payload as JsonRpcError).error,
      );
    }
  }

  // private onSessionUpdateRequest: EnginePrivate["onSessionUpdateRequest"] = async (
  //   topic,
  //   payload,
  // ) => {
  //   final { params, id } = payload;
  //   try {
  //     _isValidUpdate({ topic, ...params });
  //     await client.session.update(topic, { namespaces: params.namespaces });
  //     await _sendResult<"wc_sessionUpdate">(id, topic, true);
  //     client.events.emitData("session_update", { id, topic, params });
  //   } catch (err: any) {
  //     await _sendError(id, topic, err);
  //     client.logger.e(err);
  //   }
  // };

  // private onSessionUpdateResponse: EnginePrivate["onSessionUpdateResponse"] = (_topic, payload) => {
  //   final { id } = payload;
  //   if (isJsonRpcResult(payload)) {
  //     events.emitData(engineEvent("session_update", id), {});
  //   } else if (isJsonRpcError(payload)) {
  //     events.emitData(engineEvent("session_update", id), { error: payload.e });
  //   }
  // };

  // private onSessionExtendRequest: EnginePrivate["onSessionExtendRequest"] = async (
  //   topic,
  //   payload,
  // ) => {
  //   final { id } = payload;
  //   try {
  //     _isValidExtend({ topic });
  //     await _setExpiry(topic, calcExpiry(SESSION_EXPIRY));
  //     await _sendResult<"wc_sessionExtend">(id, topic, true);
  //     client.events.emitData("session_extend", { id, topic });
  //   } catch (err: any) {
  //     await _sendError(id, topic, err);
  //     client.logger.e(err);
  //   }
  // };

  // private onSessionExtendResponse: EnginePrivate["onSessionExtendResponse"] = (_topic, payload) => {
  //   final { id } = payload;
  //   if (isJsonRpcResult(payload)) {
  //     events.emitData(engineEvent("session_extend", id), {});
  //   } else if (isJsonRpcError(payload)) {
  //     events.emitData(engineEvent("session_extend", id), { error: payload.e });
  //   }
  // };

  // private onSessionPingRequest: EnginePrivate["onSessionPingRequest"] = async (topic, payload) => {
  //   final { id } = payload;
  //   try {
  //     _isValidPing({ topic });
  //     await _sendResult<"wc_sessionPing">(id, topic, true);
  //     client.events.emitData("session_ping", { id, topic });
  //   } catch (err: any) {
  //     await _sendError(id, topic, err);
  //     client.logger.e(err);
  //   }
  // };

  // private onSessionPingResponse: EnginePrivate["onSessionPingResponse"] = (_topic, payload) => {
  //   final { id } = payload;
  //   // put at the end of the stack to avoid a race condition
  //   // where session_ping listener is not yet _initialized
  //   setTimeout(() => {
  //     if (isJsonRpcResult(payload)) {
  //       events.emitData(engineEvent("session_ping", id), {});
  //     } else if (isJsonRpcError(payload)) {
  //       events.emitData(engineEvent("session_ping", id), { error: payload.e });
  //     }
  //   }, 500);
  // };

  // private onSessionDeleteRequest: EnginePrivate["onSessionDeleteRequest"] = async (
  //   topic,
  //   payload,
  // ) => {
  //   final { id } = payload;
  //   try {
  //     _isValidDisconnect({ topic, reason: payload.params });
  //     // RPC request needs to happen before deletion as it utalises session encryption
  //     await _sendResult<"wc_sessionDelete">(id, topic, true);
  //     await _deleteSession(topic);
  //     client.events.emitData("session_delete", { id, topic });
  //   } catch (err: any) {
  //     await _sendError(id, topic, err);
  //     client.logger.e(err);
  //   }
  // };

  // private onSessionRequest: EnginePrivate["onSessionRequest"] = async (topic, payload) => {
  //   final { id, params } = payload;
  //   try {
  //     _isValidRequest({ topic, ...params });
  //     await setPendingSessionRequest({ id, topic, params });
  //     client.events.emitData("session_request", { id, topic, params });
  //   } catch (err: any) {
  //     await _sendError(id, topic, err);
  //     client.logger.e(err);
  //   }
  // };

  // private onSessionRequestResponse: EnginePrivate["onSessionRequestResponse"] = (
  //   _topic,
  //   payload,
  // ) => {
  //   final { id } = payload;
  //   if (isJsonRpcResult(payload)) {
  //     events.emitData(engineEvent("session_request", id), { result: payload.result });
  //   } else if (isJsonRpcError(payload)) {
  //     events.emitData(engineEvent("session_request", id), { error: payload.e });
  //   }
  // };

  // private onSessionEventRequest: EnginePrivate["onSessionEventRequest"] = async (
  //   topic,
  //   payload,
  // ) => {
  //   final { id, params } = payload;
  //   try {
  //     _isValidEmit({ topic, ...params });
  //     client.events.emitData("session_event", { id, topic, params });
  //   } catch (err: any) {
  //     await _sendError(id, topic, err);
  //     client.logger.e(err);
  //   }
  // };

  // ---------- Expirer Events ---------------------------------------- //

  _registerExpirerEvents() {
    client.core.expirer.on(ExpirerEvents.expired, (event) async {
      if (event is ExpirerTypesExpiration) {
        final eventData = event.eventData as ExpirerTypesExpiration;

        final expirerTarget = parseExpirerTarget(eventData.target);
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
            client.events.emitData(
              SignClientTypesEvent.SESSION_EXPIRE.value,
              {'topic': topic},
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
          context: 'connect() relays: ${relays}');
      throw WCException(error.message);
    }
  }

  _isValidApprove(SessionApproveParams params) async {
    final id = params.id;
    final namespaces = params.namespaces;
    final relayProtocol = params.relayProtocol;

    await _isValidProposalId(id);
    final proposal = client.proposal.get(id.toString());
    final validNamespacesError = isValidNamespaces(namespaces, "approve()");
    if (validNamespacesError != null) {
      throw WCException(validNamespacesError.message);
    }
    final conformingNamespacesError = isConformingNamespaces(
      proposal.requiredNamespaces,
      namespaces,
      "update()",
    );
    if (conformingNamespacesError != null) {
      throw WCException(conformingNamespacesError.message);
    }
  }

  _isValidReject(SessionRejectParams params) async {
    await _isValidProposalId(params.id);
    if (!isValidErrorReason(params.reason)) {
      final error = getInternalError(
        InternalErrorKey.MISSING_OR_INVALID,
        context: 'reject() reason: ${params.reason.toJson()}',
      );
      throw WCException(error.message);
    }
  }

  _isValidSessionSettleRequest(SessionSettleRequestParams params) {
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

  _isValidUpdate(SessionUpdateParams params) async {
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

  _isValidExtend(String topic) async {
    await _isValidSessionTopic(topic);
  }

  _isValidRequest(SessionRequestParams params) async {
    final topic = params.topic;
    final request = params.request;
    final chainId = params.chainId;

    await _isValidSessionTopic(topic);
    final session = client.session.get(topic);
    final namespaces = session.namespaces;

    if (!isValidNamespacesChainId(namespaces, chainId)) {
      final error = getInternalError(
        InternalErrorKey.MISSING_OR_INVALID,
        context: 'request() chainId: ${chainId}',
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
        context: 'emit() event: ${event}',
      );
      throw WCException(error.message);
    }
  }

  Future<void> _isValidDisconnect(String topic) async {
    await _isValidSessionOrPairingTopic(topic);
  }
}
