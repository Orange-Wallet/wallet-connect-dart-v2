import 'package:wallet_connect/core/relayer/types.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/error.dart';
import 'package:wallet_connect/wc_utils/relay/jsonrpc.dart';
import 'package:wallet_connect/wc_utils/relay/types.dart';

const RELAYER_DEFAULT_PROTOCOL = "irn";

RelayerProtocolOptions getRelayProtocolName(dynamic opts) {
  return opts?.relay ??
      RelayerProtocolOptions(protocol: RELAYER_DEFAULT_PROTOCOL);
}

RelayJsonRpcMethods getRelayProtocolApi(String protocol) {
  final jsonrpc = RELAY_JSONRPC[protocol];
  if (jsonrpc == null) {
    throw WCException('Relay Protocol not supported: $protocol');
  }
  return jsonrpc;
}
