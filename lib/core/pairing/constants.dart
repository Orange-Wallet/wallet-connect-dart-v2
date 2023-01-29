import 'package:wallet_connect/core/pairing/models.dart';
import 'package:wallet_connect/core/relayer/models.dart';

const PAIRING_CONTEXT = "pairing";

const PAIRING_STORAGE_VERSION = "0.3";

const PAIRING_DEFAULT_TTL = 30 * 24 * 60 * 60; // 30days in secs

const ONE_DAY = 1 * 24 * 60 * 60;

const THIRTY_SECONDS = 30;

PairingJsonRpcOptions getPairingRpcOptions(PairingMethod? method) {
  switch (method) {
    case PairingMethod.WC_PAIRING_DELETE:
      return const PairingJsonRpcOptions(
        req: RelayerPublishOptions(
          ttl: ONE_DAY,
          prompt: false,
          tag: 1000,
        ),
        res: RelayerPublishOptions(
          ttl: ONE_DAY,
          prompt: false,
          tag: 1001,
        ),
      );
    case PairingMethod.WC_PAIRING_PING:
      return const PairingJsonRpcOptions(
        req: RelayerPublishOptions(
          ttl: THIRTY_SECONDS,
          prompt: false,
          tag: 1002,
        ),
        res: RelayerPublishOptions(
          ttl: THIRTY_SECONDS,
          prompt: false,
          tag: 1003,
        ),
      );
    default:
      return const PairingJsonRpcOptions(
        req: RelayerPublishOptions(
          ttl: ONE_DAY,
          prompt: false,
          tag: 0,
        ),
        res: RelayerPublishOptions(
          ttl: ONE_DAY,
          prompt: false,
          tag: 0,
        ),
      );
  }
}
