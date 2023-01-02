import 'package:logger/logger.dart';
import 'package:wallet_connect/core/core/types.dart';
import 'package:wallet_connect/sign/engine/types.dart';
import 'package:wallet_connect/sign/sign-client/pendingRequest/types.dart';
import 'package:wallet_connect/sign/sign-client/proposal/types.dart';
import 'package:wallet_connect/sign/sign-client/session/types.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';

enum SignClientTypesEvent {
  SESSION_PROPOSAL,
  SESSION_UPDATE,
  SESSION_EXTEND,
  SESSION_PING,
  SESSION_DELETE,
  SESSION_EXPIRE,
  SESSION_REQUEST,
  SESSION_EVENT,
  PROPOSAL_EXPIRE,
}

Map<SignClientTypesEvent, String> _signClientTypesEventMap = {
  SignClientTypesEvent.SESSION_PROPOSAL: "session_proposal",
  SignClientTypesEvent.SESSION_UPDATE: "session_update",
  SignClientTypesEvent.SESSION_EXTEND: "session_extend",
  SignClientTypesEvent.SESSION_PING: "session_ping",
  SignClientTypesEvent.SESSION_DELETE: "session_delete",
  SignClientTypesEvent.SESSION_EXPIRE: "session_expire",
  SignClientTypesEvent.SESSION_REQUEST: "session_request",
  SignClientTypesEvent.SESSION_EVENT: "session_event",
  SignClientTypesEvent.PROPOSAL_EXPIRE: "proposal_expire",
};

extension SignClientTypesEventExt on SignClientTypesEvent {
  String get value {
    return _signClientTypesEventMap[this]!;
  }
}

extension SignClientTypesEventExtStr on String {
  SignClientTypesEvent get signClientEvent {
    return _signClientTypesEventMap.entries
        .where((element) => element.value == this)
        .first
        .key;
  }
}

abstract class ISignClient {
  String get name;
  Metadata get metadata;

  ICore get core;
  Logger get logger;
  EventSubject get events;
  IEngine get engine;
  ISession get session;
  IProposal get proposal;
  IPendingRequest get pendingRequest;

  // public abstract connect: IEngine["connect"];
  // public abstract pair: IEngine["pair"];
  // public abstract approve: IEngine["approve"];
  // public abstract reject: IEngine["reject"];
  // public abstract update: IEngine["update"];
  // public abstract extend: IEngine["extend"];
  // public abstract request: IEngine["request"];
  // public abstract respond: IEngine["respond"];
  // public abstract ping: IEngine["ping"];
  // public abstract emit: IEngine["emit"];
  // public abstract disconnect: IEngine["disconnect"];
  // public abstract find: IEngine["find"];
}
