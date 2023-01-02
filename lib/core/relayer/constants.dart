const RELAYER_DEFAULT_PROTOCOL = "irn";

const RELAYER_DEFAULT_LOGGER = "error";

const RELAYER_DEFAULT_RELAY_URL = "wss://relay.walletconnect.com";

const RELAYER_CONTEXT = "relayer";

class RelayerEvents {
  RelayerEvents._();

  static const String message = "relayer_message";
  static const String connect = "relayer_connect";
  static const String disconnect = "relayer_disconnect";
  static const String error = "relayer_error";
}

const RELAYER_SUBSCRIBER_SUFFIX = "_subscription";

class RelayerProviderEvents {
  RelayerProviderEvents._();

  static const String payload = "payload";
  static const String connect = "connect";
  static const String disconnect = "disconnect";
  static const String error = "error";
}

const RELAYER_RECONNECT_TIMEOUT = 1; // 1 sec

class RelayerStorageOptions {
  static const database = ":memory:";
}

// Updated automatically via `new-version` npm script.
const RELAYER_SDK_VERSION = "2.1.3";
