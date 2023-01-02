import 'dart:typed_data';

import 'package:logger/logger.dart';
import 'package:wallet_connect/core/core/types.dart';
import 'package:wallet_connect/core/keychain/types.dart';

class CryptoTypesParticipant {
  final String publicKey;

  CryptoTypesParticipant({required this.publicKey});
}

class CryptoTypesKeyPair {
  final String privateKey;
  final String publicKey;

  CryptoTypesKeyPair({
    required this.privateKey,
    required this.publicKey,
  });
}

class CryptoTypesEncryptParams {
  final String message;
  final String symKey;
  final int? type;
  final String? iv;
  final String? senderPublicKey;

  CryptoTypesEncryptParams({
    required this.message,
    required this.symKey,
    this.type,
    this.iv,
    this.senderPublicKey,
  });
}

class CryptoTypesDecryptParams {
  final String symKey;
  final String encoded;

  CryptoTypesDecryptParams({
    required this.symKey,
    required this.encoded,
  });
}

class CryptoTypesEncodingParams {
  final Uint8List type;
  final Uint8List sealed;
  final Uint8List iv;
  final Uint8List? senderPublicKey;

  CryptoTypesEncodingParams({
    required this.type,
    required this.sealed,
    required this.iv,
    this.senderPublicKey,
  });
}

class CryptoTypesEncodeOptions {
  final int? type;
  final String? senderPublicKey;
  final String? receiverPublicKey;

  CryptoTypesEncodeOptions({
    this.type,
    this.senderPublicKey,
    this.receiverPublicKey,
  });
}

class CryptoTypesDecodeOptions {
  final String? receiverPublicKey;

  CryptoTypesDecodeOptions({this.receiverPublicKey});
}

class CryptoTypesEncodingValidation {
  final int type;
  final String? senderPublicKey;
  final String? receiverPublicKey;

  CryptoTypesEncodingValidation({
    required this.type,
    this.senderPublicKey,
    this.receiverPublicKey,
  });
}

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
    CryptoTypesEncodeOptions? opts,
  });

  Future<dynamic> decode({
    required String topic,
    required String encoded,
    CryptoTypesDecodeOptions? opts,
  });

  Future<String> signJWT(String aud);

  int getPayloadType(String encoded);
}
