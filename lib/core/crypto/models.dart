import 'dart:typed_data';

class CryptoParticipant {
  final String publicKey;

  CryptoParticipant({required this.publicKey});
}

class CryptoKeyPair {
  final String privateKey;
  final String publicKey;

  const CryptoKeyPair({
    required this.privateKey,
    required this.publicKey,
  });
}

class CryptoEncryptParams {
  final String message;
  final String symKey;
  final int? type;
  final String? iv;
  final String? senderPublicKey;

  CryptoEncryptParams({
    required this.message,
    required this.symKey,
    this.type,
    this.iv,
    this.senderPublicKey,
  });
}

class CryptoDecryptParams {
  final String symKey;
  final String encoded;

  CryptoDecryptParams({
    required this.symKey,
    required this.encoded,
  });
}

class CryptoEncodingParams {
  final Uint8List type;
  final Uint8List sealed;
  final Uint8List iv;
  final Uint8List? senderPublicKey;

  CryptoEncodingParams({
    required this.type,
    required this.sealed,
    required this.iv,
    this.senderPublicKey,
  });
}

class CryptoEncodeOptions {
  final int? type;
  final String? senderPublicKey;
  final String? receiverPublicKey;

  CryptoEncodeOptions({
    this.type,
    this.senderPublicKey,
    this.receiverPublicKey,
  });
}

class CryptoDecodeOptions {
  final String? receiverPublicKey;

  CryptoDecodeOptions({this.receiverPublicKey});
}

class CryptoEncodingValidation {
  final int type;
  final String? senderPublicKey;
  final String? receiverPublicKey;

  CryptoEncodingValidation({
    required this.type,
    this.senderPublicKey,
    this.receiverPublicKey,
  });
}
