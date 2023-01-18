import 'package:wallet_connect/core/pairing/models.dart';
import 'package:wallet_connect/core/relayer/models.dart';
import 'package:wallet_connect/sign/engine/models.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/error.dart';

const ENGINE_CONTEXT = "engine";

const FIVE_MINUTES = 5 * 60;
const ONE_DAY = 1 * 24 * 60 * 60;
const THIRTY_SECONDS = 30;

PairingJsonRpcOptions getEngineRpcOptions(JsonRpcMethod method) {
  switch (method) {
    case JsonRpcMethod.WC_SESSION_PROPOSE:
      return const PairingJsonRpcOptions(
        req: RelayerPublishOptions(
          ttl: FIVE_MINUTES,
          prompt: true,
          tag: 1100,
        ),
        res: RelayerPublishOptions(
          ttl: FIVE_MINUTES,
          prompt: false,
          tag: 1101,
        ),
      );
    case JsonRpcMethod.WC_SESSION_SETTLE:
      return const PairingJsonRpcOptions(
        req: RelayerPublishOptions(
          ttl: FIVE_MINUTES,
          prompt: false,
          tag: 1102,
        ),
        res: RelayerPublishOptions(
          ttl: FIVE_MINUTES,
          prompt: false,
          tag: 1103,
        ),
      );
    case JsonRpcMethod.WC_SESSION_REQUEST:
      return const PairingJsonRpcOptions(
        req: RelayerPublishOptions(
          ttl: ONE_DAY,
          prompt: false,
          tag: 1104,
        ),
        res: RelayerPublishOptions(
          ttl: ONE_DAY,
          prompt: false,
          tag: 1105,
        ),
      );
    case JsonRpcMethod.WC_SESSION_DELETE:
      return const PairingJsonRpcOptions(
        req: RelayerPublishOptions(
          ttl: ONE_DAY,
          prompt: false,
          tag: 1106,
        ),
        res: RelayerPublishOptions(
          ttl: ONE_DAY,
          prompt: false,
          tag: 1107,
        ),
      );
    case JsonRpcMethod.WC_SESSION_PING:
      return const PairingJsonRpcOptions(
        req: RelayerPublishOptions(
          ttl: FIVE_MINUTES,
          prompt: true,
          tag: 1108,
        ),
        res: RelayerPublishOptions(
          ttl: FIVE_MINUTES,
          prompt: false,
          tag: 1109,
        ),
      );
    case JsonRpcMethod.WC_SESSION_EVENT:
      return const PairingJsonRpcOptions(
        req: RelayerPublishOptions(
          ttl: FIVE_MINUTES,
          prompt: true,
          tag: 1110,
        ),
        res: RelayerPublishOptions(
          ttl: FIVE_MINUTES,
          prompt: false,
          tag: 1111,
        ),
      );
    case JsonRpcMethod.WC_SESSION_UPDATE:
      return const PairingJsonRpcOptions(
        req: RelayerPublishOptions(
          ttl: ONE_DAY,
          prompt: false,
          tag: 1112,
        ),
        res: RelayerPublishOptions(
          ttl: ONE_DAY,
          prompt: false,
          tag: 1113,
        ),
      );
    case JsonRpcMethod.WC_SESSION_EXTEND:
      return const PairingJsonRpcOptions(
        req: RelayerPublishOptions(
          ttl: THIRTY_SECONDS,
          prompt: false,
          tag: 1114,
        ),
        res: RelayerPublishOptions(
          ttl: THIRTY_SECONDS,
          prompt: false,
          tag: 1115,
        ),
      );
    default:
      throw WCException('Invalid EngineRPCOpts');
  }
}
