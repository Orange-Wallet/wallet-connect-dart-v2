import 'package:wallet_connect/core/pairing/types.dart';
import 'package:wallet_connect/core/relayer/types.dart';
import 'package:wallet_connect/sign/engine/types.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/error.dart';

const ENGINE_CONTEXT = "engine";

const FIVE_MINUTES = 5 * 60;
const ONE_DAY = 1 * 24 * 60 * 60;
const THIRTY_SECONDS = 30;

PairingJsonRpcOptions getEngineRpcOptions(JsonRpcMethod method) {
  switch (method) {
    case JsonRpcMethod.WC_SESSION_PROPOSE:
      return PairingJsonRpcOptions(
        req: RelayerTypesPublishOptions(
          ttl: FIVE_MINUTES,
          prompt: true,
          tag: 1100,
        ),
        res: RelayerTypesPublishOptions(
          ttl: FIVE_MINUTES,
          prompt: false,
          tag: 1101,
        ),
      );
    case JsonRpcMethod.WC_SESSION_SETTLE:
      return PairingJsonRpcOptions(
        req: RelayerTypesPublishOptions(
          ttl: FIVE_MINUTES,
          prompt: false,
          tag: 1102,
        ),
        res: RelayerTypesPublishOptions(
          ttl: FIVE_MINUTES,
          prompt: false,
          tag: 1103,
        ),
      );
    case JsonRpcMethod.WC_SESSION_REQUEST:
      return PairingJsonRpcOptions(
        req: RelayerTypesPublishOptions(
          ttl: ONE_DAY,
          prompt: false,
          tag: 1104,
        ),
        res: RelayerTypesPublishOptions(
          ttl: ONE_DAY,
          prompt: false,
          tag: 1105,
        ),
      );
    case JsonRpcMethod.WC_SESSION_DELETE:
      return PairingJsonRpcOptions(
        req: RelayerTypesPublishOptions(
          ttl: ONE_DAY,
          prompt: false,
          tag: 1106,
        ),
        res: RelayerTypesPublishOptions(
          ttl: ONE_DAY,
          prompt: false,
          tag: 1107,
        ),
      );
    case JsonRpcMethod.WC_SESSION_PING:
      return PairingJsonRpcOptions(
        req: RelayerTypesPublishOptions(
          ttl: FIVE_MINUTES,
          prompt: true,
          tag: 1108,
        ),
        res: RelayerTypesPublishOptions(
          ttl: FIVE_MINUTES,
          prompt: false,
          tag: 1109,
        ),
      );
    case JsonRpcMethod.WC_SESSION_EVENT:
      return PairingJsonRpcOptions(
        req: RelayerTypesPublishOptions(
          ttl: FIVE_MINUTES,
          prompt: true,
          tag: 1110,
        ),
        res: RelayerTypesPublishOptions(
          ttl: FIVE_MINUTES,
          prompt: false,
          tag: 1111,
        ),
      );
    case JsonRpcMethod.WC_SESSION_UPDATE:
      return PairingJsonRpcOptions(
        req: RelayerTypesPublishOptions(
          ttl: ONE_DAY,
          prompt: false,
          tag: 1112,
        ),
        res: RelayerTypesPublishOptions(
          ttl: ONE_DAY,
          prompt: false,
          tag: 1113,
        ),
      );
    case JsonRpcMethod.WC_SESSION_EXTEND:
      return PairingJsonRpcOptions(
        req: RelayerTypesPublishOptions(
          ttl: THIRTY_SECONDS,
          prompt: false,
          tag: 1114,
        ),
        res: RelayerTypesPublishOptions(
          ttl: THIRTY_SECONDS,
          prompt: false,
          tag: 1115,
        ),
      );
    default:
      throw WCException('Invalid EngineRPCOpts');
  }
}
