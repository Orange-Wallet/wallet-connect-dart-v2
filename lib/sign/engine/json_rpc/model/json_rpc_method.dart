// ignore_for_file: constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

enum JsonRpcMethod {
  @JsonValue("wc_sessionPropose")
  WC_SESSION_PROPOSE,
  @JsonValue("wc_sessionSettle")
  WC_SESSION_SETTLE,
  @JsonValue("wc_sessionRequest")
  WC_SESSION_REQUEST,
  @JsonValue("wc_sessionDelete")
  WC_SESSION_DELETE,
  @JsonValue("wc_sessionPing")
  WC_SESSION_PING,
  @JsonValue("wc_sessionEvent")
  WC_SESSION_EVENT,
  @JsonValue("wc_sessionUpdate")
  WC_SESSION_UPDATE,
  @JsonValue("wc_sessionExtend")
  WC_SESSION_EXTEND,
}
