import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:cryptography/dart.dart';
import 'package:wallet_connect/core/crypto/types.dart';
import 'package:cryptography/cryptography.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/error.dart';

const TYPE_0 = 0;
const TYPE_1 = 1;

const ZERO_INDEX = 0;
const TYPE_LENGTH = 1;
const IV_LENGTH = 12;
const KEY_LENGTH = 32;

Future<CryptoTypesKeyPair> generateKeyPair() async {
  final keyPair = await const DartX25519().newKeyPair();
  return CryptoTypesKeyPair(
    privateKey: hex.encode((await keyPair.extractPrivateKeyBytes())),
    publicKey: hex.encode((await keyPair.extractPublicKey()).bytes),
  );
}

List<int> randomBytes(int length) {
  final random = Random.secure();
  return List<int>.generate(length, (i) => random.nextInt(256));
}

String generateRandomBytes32() {
  final random = randomBytes(KEY_LENGTH);
  return hex.encode(random);
}

Future<String> deriveSymKey(String privateKeyA, String publicKeyB) async {
  const type = KeyPairType.x25519;
  final privateKeyBytes = hex.decode(privateKeyA);
  final publicKeyBytes = hex.decode(publicKeyB);
  final publicKey = SimplePublicKey(publicKeyBytes, type: type);
  final keyPair =
      SimpleKeyPairData(privateKeyBytes, publicKey: publicKey, type: type);
  final sharedKey = await Cryptography.instance.x25519().sharedSecretKey(
        keyPair: keyPair,
        remotePublicKey: publicKey,
      );
  final hkdf = Hkdf(hmac: Hmac(Sha256()), outputLength: KEY_LENGTH);
  final symKey = await hkdf.deriveKey(secretKey: sharedKey);
  return hex.encode(await symKey.extractBytes());
}

Future<String> hashKey(String key) async {
  final result = (await Sha256().hash(hex.decode(key))).bytes;
  return hex.encode(result);
}

Future<String> hashMessage(String message) async {
  final result = (await Sha256().hash(utf8.encode(message))).bytes;
  return hex.encode(result);
}

Uint8List encodeTypeByte(int type) {
  return _encodeBigIntAsUnsigned(BigInt.from(type));
}

int decodeTypeByte(Uint8List byte) {
  return _decodeBigIntWithSign(1, byte).toInt();
}

Future<String> encrypt({
  required String message,
  required String symKey,
  int? type,
  String? iv,
  String? senderPublicKey,
}) async {
  final typeByte = encodeTypeByte(type ?? TYPE_0);
  if (decodeTypeByte(typeByte) == TYPE_1 && senderPublicKey == null) {
    throw WCException("Missing sender public key for type 1 envelope");
  }
  final dSenderPublicKey = senderPublicKey != null
      ? Uint8List.fromList(hex.decode(senderPublicKey))
      : null;

  final dIV =
      Uint8List.fromList(iv != null ? hex.decode(iv) : randomBytes(IV_LENGTH));
  final box = await Chacha20.poly1305Aead().encrypt(utf8.encode(message),
      secretKey: SecretKey(hex.decode(symKey)), nonce: dIV);
  final sealed = Uint8List.fromList(box.cipherText);
  return serialize(
    type: typeByte,
    sealed: sealed,
    iv: dIV,
    senderPublicKey: dSenderPublicKey,
  );
}

Future<String> decrypt({
  required String symKey,
  required String encoded,
}) async {
  final decoded = deserialize(encoded);
  try {
    final secretKey = SecretKey(hex.decode(symKey));
    final mac = await Chacha20.poly1305Aead()
        .macAlgorithm
        .calculateMac(decoded.sealed, secretKey: secretKey, nonce: decoded.iv);
    final message = await Chacha20.poly1305Aead().decrypt(
      SecretBox(decoded.sealed, nonce: decoded.iv, mac: mac),
      secretKey: secretKey,
    );
    return utf8.decode(message);
  } catch (e) {
    throw WCException("Failed to decrypt");
  }
}

String serialize({
  required Uint8List type,
  required Uint8List sealed,
  required Uint8List iv,
  Uint8List? senderPublicKey,
}) {
  if (decodeTypeByte(type) == TYPE_1) {
    if (senderPublicKey == null) {
      throw WCException("Missing sender public key for type 1 envelope");
    }
    return base64Encode([...type, ...senderPublicKey, ...iv, ...sealed]);
  }
  // default to type 0 envelope
  return base64Encode([...type, ...iv, ...sealed]);
}

CryptoTypesEncodingParams deserialize(String encoded) {
  final bytes = base64Decode(encoded);
  final type = bytes.sublist(ZERO_INDEX, TYPE_LENGTH);
  final slice1 = TYPE_LENGTH;
  if (decodeTypeByte(type) == TYPE_1) {
    final slice2 = slice1 + KEY_LENGTH;
    final slice3 = slice2 + IV_LENGTH;
    final senderPublicKey = bytes.sublist(slice1, slice2);
    final iv = bytes.sublist(slice2, slice3);
    final sealed = bytes.sublist(slice3);
    return CryptoTypesEncodingParams(
      type: type,
      sealed: sealed,
      iv: iv,
      senderPublicKey: senderPublicKey,
    );
  }
  // default to type 0 envelope
  final slice2 = slice1 + IV_LENGTH;
  final iv = bytes.sublist(slice1, slice2);
  final sealed = bytes.sublist(slice2);
  return CryptoTypesEncodingParams(
    type: type,
    sealed: sealed,
    iv: iv,
  );
}

CryptoTypesEncodingValidation validateDecoding({
  required String encoded,
  CryptoTypesDecodeOptions? opts,
}) {
  final deserialized = deserialize(encoded);
  return validateEncoding(CryptoTypesEncodeOptions(
    type: decodeTypeByte(deserialized.type),
    senderPublicKey: deserialized.senderPublicKey != null
        ? hex.encode(deserialized.senderPublicKey!)
        : null,
    receiverPublicKey: opts?.receiverPublicKey,
  ));
}

CryptoTypesEncodingValidation validateEncoding(
    [CryptoTypesEncodeOptions? opts]) {
  final type = opts?.type ?? TYPE_0;
  if (type == TYPE_1) {
    if (opts?.senderPublicKey == null) {
      throw WCException("missing sender public key");
    }
    if (opts?.receiverPublicKey == null) {
      throw WCException("missing receiver public key");
    }
  }
  return CryptoTypesEncodingValidation(
    type: type,
    senderPublicKey: opts?.senderPublicKey,
    receiverPublicKey: opts?.receiverPublicKey,
  );
}

bool isTypeOneEnvelope(CryptoTypesEncodingValidation result) {
  return (result.type == TYPE_1 &&
      result.senderPublicKey != null &&
      result.receiverPublicKey != null);
}

//
BigInt _decodeBigIntWithSign(int sign, List<int> magnitude) {
  if (sign == 0) {
    return BigInt.zero;
  }

  BigInt result;

  if (magnitude.length == 1) {
    result = BigInt.from(magnitude[0]);
  } else {
    result = BigInt.from(0);
    for (var i = 0; i < magnitude.length; i++) {
      var item = magnitude[magnitude.length - i - 1];
      result |= (BigInt.from(item) << (8 * i));
    }
  }

  if (result != BigInt.zero) {
    if (sign < 0) {
      result = result.toSigned(result.bitLength);
    } else {
      result = result.toUnsigned(result.bitLength);
    }
  }
  return result;
}

//
Uint8List _encodeBigIntAsUnsigned(BigInt number) {
  var byteMask = BigInt.from(0xff);
  if (number == BigInt.zero) {
    return Uint8List.fromList([0]);
  }
  var size = number.bitLength + (number.isNegative ? 8 : 7) >> 3;
  var result = Uint8List(size);
  for (var i = 0; i < size; i++) {
    result[size - i - 1] = (number & byteMask).toInt();
    number = number >> 8;
  }
  return result;
}
