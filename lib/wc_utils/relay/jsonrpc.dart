import 'package:wallet_connect_v2/wc_utils/relay/models.dart';

const RELAY_JSONRPC = {
  'waku': RelayJsonRpcMethods(
    publish: "waku_publish",
    subscribe: "waku_subscribe",
    subscription: "waku_subscription",
    unsubscribe: "waku_unsubscribe",
  ),
  'irn': RelayJsonRpcMethods(
    publish: "irn_publish",
    subscribe: "irn_subscribe",
    subscription: "irn_subscription",
    unsubscribe: "irn_unsubscribe",
  ),
  'iridium': RelayJsonRpcMethods(
    publish: "iridium_publish",
    subscribe: "iridium_subscribe",
    subscription: "iridium_subscription",
    unsubscribe: "iridium_unsubscribe",
  ),
};
