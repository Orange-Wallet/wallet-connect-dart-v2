import 'package:wallet_connect/wc_utils/jsonrpc/types.dart';

bool isJsonRpcPayload(dynamic payload) {
  return (payload is Map &&
      payload.containsKey('id') &&
      payload.containsKey('jsonrpc') &&
      payload['jsonrpc'] == '2.0');
}

bool isJsonRpcRequest(dynamic payload) {
  return payload is JsonRpcRequest ||
      (payload is Map &&
          isJsonRpcPayload(payload) &&
          payload.containsKey('method'));
}

bool isJsonRpcResponse(dynamic payload) {
  return isJsonRpcPayload(payload) &&
      (isJsonRpcResult(payload) || isJsonRpcError(payload));
}

bool isJsonRpcResult(dynamic payload) {
  return payload is JsonRpcResult ||
      (payload is Map && payload.containsKey('result'));
}

bool isJsonRpcError(dynamic payload) {
  return payload is JsonRpcError ||
      payload is Map && payload.containsKey('error');
}
