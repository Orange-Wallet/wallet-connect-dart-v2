const SIGN_CLIENT_PROTOCOL = "wc";
const SIGN_CLIENT_VERSION = 2;
const SIGN_CLIENT_CONTEXT = "client";

const SIGN_CLIENT_STORAGE_PREFIX =
    '$SIGN_CLIENT_PROTOCOL@$SIGN_CLIENT_VERSION:$SIGN_CLIENT_CONTEXT:';

class SignClientDefault {
  SignClientDefault._();

  static const String name = SIGN_CLIENT_CONTEXT;
  static const String logger = "error";
  static const bool controller = false;
  static const String relayUrl = "wss://relay.walletconnect.com";
}
