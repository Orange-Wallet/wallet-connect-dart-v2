import 'dart:math' as math;

import 'package:wallet_connect/wc_utils/jsonrpc/types.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/constants.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/error.dart';

int payloadId() {
  final date =
      (DateTime.now().millisecondsSinceEpoch * math.pow(10, 3)).toInt();
  final extra = (math.Random().nextDouble() * math.pow(10, 3)).floor();
  return date + extra;
}

JsonRpcRequest<T> formatJsonRpcRequest<T>({
  required String method,
  T? params,
  int? id,
}) {
  return JsonRpcRequest<T>(
    id: id ?? payloadId(),
    jsonrpc: "2.0",
    method: method,
    params: params,
  );
}

JsonRpcResult<T> formatJsonRpcResult<T>(int id, T result) {
  return JsonRpcResult<T>(id: id, jsonrpc: '2.0', result: result);
}

formatJsonRpcError({
  required int id,
  dynamic error,
  String? data,
}) {
  return JsonRpcResult(
    id: id,
    jsonrpc: "2.0",
    error: formatErrorMessage(error: error, data: data),
  );
}

ErrorResponse formatErrorMessage({dynamic error, String? data}) {
  if (error == null) {
    return getError(INTERNAL_ERROR);
  }
  ErrorResponse? _error;
  if (error is String) {
    _error = getError(SERVER_ERROR).copyWith(
      message: error,
    );
  } else if (error is ErrorResponse) {
    _error = error;
  }

  if (data != null) {
    _error = _error!.copyWith(data: data);
  }
  if (isReservedErrorCode(error.code)) {
    _error = getErrorByCode(error.code);
  }
  return _error!;
}
