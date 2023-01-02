import 'package:wallet_connect/core/pairing/types.dart';
import 'package:wallet_connect/core/relayer/types.dart';

const PAIRING_CONTEXT = "pairing";

const PAIRING_STORAGE_VERSION = "0.3";

const PAIRING_DEFAULT_TTL = 30 * 24 * 60 * 60; // 30days in secs

const ONE_DAY = 1 * 24 * 60 * 60;

const THIRTY_SECONDS = 30;

PairingJsonRpcOptions getPairingRpcOptions(PairingRpcMethod? method) {
  switch (method) {
    case PairingRpcMethod.WC_PAIRING_DELETE:
      return PairingJsonRpcOptions(
        req: RelayerTypesPublishOptions(
          ttl: ONE_DAY,
          prompt: false,
          tag: 1000,
        ),
        res: RelayerTypesPublishOptions(
          ttl: ONE_DAY,
          prompt: false,
          tag: 1001,
        ),
      );
    case PairingRpcMethod.WC_PAIRING_PING:
      return PairingJsonRpcOptions(
        req: RelayerTypesPublishOptions(
          ttl: THIRTY_SECONDS,
          prompt: false,
          tag: 1002,
        ),
        res: RelayerTypesPublishOptions(
          ttl: THIRTY_SECONDS,
          prompt: false,
          tag: 1003,
        ),
      );
    default:
      return PairingJsonRpcOptions(
        req: RelayerTypesPublishOptions(
          ttl: ONE_DAY,
          prompt: false,
          tag: 0,
        ),
        res: RelayerTypesPublishOptions(
          ttl: ONE_DAY,
          prompt: false,
          tag: 0,
        ),
      );
  }
}
