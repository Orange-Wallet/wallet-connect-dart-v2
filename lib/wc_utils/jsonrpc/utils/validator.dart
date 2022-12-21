bool isJsonRpcPayload(dynamic payload) {
  return (payload is Map &&
      payload.containsKey('id') &&
      payload.containsKey('jsonrpc') &&
      payload['jsonrpc'] == '2.0');
}

bool isJsonRpcRequest(dynamic payload) {
  return payload is Map &&
      isJsonRpcPayload(payload) &&
      payload.containsKey('method');
}
