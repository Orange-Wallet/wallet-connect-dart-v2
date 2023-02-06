import 'package:logger/logger.dart';
import 'package:walletconnect_v2/core/crypto/models.dart';
import 'package:walletconnect_v2/core/i_core.dart';
import 'package:walletconnect_v2/core/keychain/i_key_chain.dart';

abstract class ICrypto {
  String get name;

  IKeyChain get keychain;

  ICore get core;

  Logger get logger;

  Future<void> init();

  bool hasKeys(String tag);

  Future<String> getClientId();

  Future<String> generateKeyPair();

  Future<String> generateSharedKey({
    required String selfPublicKey,
    required String peerPublicKey,
    String? overrideTopic,
  });

  Future<String> setSymKey({required String symKey, String? overrideTopic});

  Future<void> deleteKeyPair({required String publicKey});

  Future<void> deleteSymKey({required String topic});

  Future<String> encode({
    required String topic,
    required Object payload,
    CryptoEncodeOptions? opts,
  });

  Future<dynamic> decode({
    required String topic,
    required String encoded,
    CryptoDecodeOptions? opts,
  });

  Future<String> signJWT(String aud);

  int getPayloadType(String encoded);
}
