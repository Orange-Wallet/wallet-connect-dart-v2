class SignClientEventParams<T> {
  final int? id;
  final String? topic;
  final T? params;

  SignClientEventParams({
    this.id,
    this.topic,
    this.params,
  });
}

enum SignClientEvent {
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

Map<SignClientEvent, String> _signClientTypesEventMap = {
  SignClientEvent.SESSION_PROPOSAL: "session_proposal",
  SignClientEvent.SESSION_UPDATE: "session_update",
  SignClientEvent.SESSION_EXTEND: "session_extend",
  SignClientEvent.SESSION_PING: "session_ping",
  SignClientEvent.SESSION_DELETE: "session_delete",
  SignClientEvent.SESSION_EXPIRE: "session_expire",
  SignClientEvent.SESSION_REQUEST: "session_request",
  SignClientEvent.SESSION_EVENT: "session_event",
  SignClientEvent.PROPOSAL_EXPIRE: "proposal_expire",
};

extension SignClientEventX on SignClientEvent {
  String get value {
    return _signClientTypesEventMap[this]!;
  }
}

extension SignClientEventStringX on String {
  SignClientEvent get signClientEvent {
    return _signClientTypesEventMap.entries
        .where((element) => element.value == this)
        .first
        .key;
  }
}
