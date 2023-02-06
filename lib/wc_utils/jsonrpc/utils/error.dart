import 'package:wallet_connect_dart_v2/wc_utils/jsonrpc/models/models.dart';
import 'package:wallet_connect_dart_v2/wc_utils/jsonrpc/utils/constants.dart';

bool isServerErrorCode(int code) {
  return code <= SERVER_ERROR_CODE_RANGE[0] &&
      code >= SERVER_ERROR_CODE_RANGE[1];
}

bool isReservedErrorCode(int code) {
  return RESERVED_ERROR_CODES.contains(code);
}

ErrorResponse getError(String type) {
  if (!STANDARD_ERROR_MAP.containsKey(type)) {
    return STANDARD_ERROR_MAP[DEFAULT_ERROR]!;
  }
  return STANDARD_ERROR_MAP[type]!;
}

ErrorResponse getErrorByCode(int code) {
  final match = STANDARD_ERROR_MAP.entries.where((e) => e.value.code == code);
  if (match.isEmpty) {
    return STANDARD_ERROR_MAP[DEFAULT_ERROR]!;
  }
  return match.first.value;
}

WCException parseConnectionError(WCException e, String url, String type) {
  return (e.message != null && e.message!.contains("getaddrinfo ENOTFOUND") ||
          e.message!.contains("connect ECONNREFUSED"))
      ? WCException('Unavailable $type RPC url at $url')
      : e;
}

class WCException implements Exception {
  final String? message;

  WCException([this.message]);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WCException && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'WCException(message: $message)';
}
