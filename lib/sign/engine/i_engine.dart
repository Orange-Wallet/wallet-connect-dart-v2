import 'package:wallet_connect/core/pairing/models.dart';
import 'package:wallet_connect/sign/engine/models.dart';
import 'package:wallet_connect/sign/sign-client/client/i_sign_client.dart';
import 'package:wallet_connect/sign/sign-client/pending_request/models.dart';
import 'package:wallet_connect/sign/sign-client/session/models.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/models/models.dart';

abstract class IEngine {
  ISignClient get client;

  Future<void> init();

  Future<EngineConnection> connect(SessionConnectParams params);

  Future<PairingStruct> pair(String uri);

  Future<EngineApproved> approve(SessionApproveParams params);

  Future<void> reject(SessionRejectParams params);

  Future<EngineAcknowledged> update(SessionUpdateParams params);

  Future<EngineAcknowledged> extend(String topic);

  Future<T> request<T>(SessionRequestParams params);

  Future<void> respond(SessionRespondParams params);

  Future<void> ping(String topic);

  Future<void> emit(SessionEmitParams params);

  Future<void> disconnect({
    required String topic,
    ErrorResponse? reason,
  });

  List<SessionStruct> find(params);

  List<PendingRequestStruct> getPendingSessionRequests();
}
