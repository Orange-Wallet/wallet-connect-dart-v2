import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart' as crypto;
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/hkdf.dart';
import 'package:pointycastle/pointycastle.dart' as pc;
import 'package:wallet_connect_dart_v2/core/crypto/models.dart';
import 'package:wallet_connect_dart_v2/wc_utils/jsonrpc/utils/error.dart';
import 'package:wallet_connect_dart_v2/utils/yx_util/yx_crypto.dart';
import 'package:x25519/x25519.dart' as curve;

const TYPE_0 = 0;
const TYPE_1 = 1;

const ZERO_INDEX = 0;
const TYPE_LENGTH = 1;
const IV_LENGTH = 12;
const KEY_LENGTH = 32;

Future<CryptoKeyPair> generateKeyPair() async {
  final keyPair = curve.generateKeyPair();
  return CryptoKeyPair(
    privateKey: hex.encode(keyPair.privateKey),
    publicKey: hex.encode(keyPair.publicKey),
  );
}

List<int> randomBytes(int length) {
  final random = math.Random.secure();
  return List<int>.generate(length, (i) => random.nextInt(256));
}

String generateRandomBytes32() {
  final random = randomBytes(KEY_LENGTH);
  return hex.encode(random);
}

Future<String> deriveSymKey(String privateKeyA, String publicKeyB) async {
  final privateKeyBytes = hex.decode(privateKeyA);
  final publicKeyBytes = hex.decode(publicKeyB);
  // final sharedKey = await crypto.X25519().sharedSecretKey(
  //       keyPair: crypto.SimpleKeyPair(
  //         privateKeyBytes,
  //       ),
  //       remotePublicKey: remotePublicKey,
  //     );

  final sharedKey = curve.X25519(privateKeyBytes, publicKeyBytes);
  var okm = Uint8List(KEY_LENGTH);
  final hkdfX = HKDFKeyDerivator(SHA256Digest())
    ..init(pc.HkdfParameters(sharedKey, KEY_LENGTH));
  hkdfX.deriveKey(null, 0, okm, 0);

  // final hkdf = DartHkdf(
  //   hmac: DartHmac(DartSha256()),
  //   outputLength: KEY_LENGTH,
  // );

  // final symKey = await hkdf.deriveKey(
  //     secretKey: await crypto.SecretKeyData.random(length: 32).extract());
  // return hex.encode(await symKey.extractBytes());
  return hex.encode(okm);
}

Future<String> hashKey(String key) async {
  final result = (await crypto.Sha256().hash(hex.decode(key))).bytes;
  return hex.encode(result);
}

Future<String> hashMessage(String message) async {
  final result = (await crypto.Sha256().hash(utf8.encode(message))).bytes;
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

  final box = AEADChaCha20Poly1305.withIV(
    Uint8List.fromList(hex.decode(symKey)),
    dIV,
  );
  final sealed = box.encrypt(Uint8List.fromList(utf8.encode(message)));
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
    final box = AEADChaCha20Poly1305.withIV(
      Uint8List.fromList(hex.decode(symKey)),
      decoded.iv,
    );
    final message = box.decrypt(decoded.sealed.toList());
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

CryptoEncodingParams deserialize(String encoded) {
  final bytes = Uint8List.fromList(base64.decode(encoded));
  final type = bytes.sublist(ZERO_INDEX, TYPE_LENGTH);
  final slice1 = TYPE_LENGTH;
  if (decodeTypeByte(type) == TYPE_1) {
    final slice2 = slice1 + KEY_LENGTH;
    final slice3 = slice2 + IV_LENGTH;
    final senderPublicKey = bytes.sublist(slice1, slice2);
    final iv = bytes.sublist(slice2, slice3);
    final sealed = bytes.sublist(slice3);
    return CryptoEncodingParams(
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
  return CryptoEncodingParams(
    type: type,
    sealed: sealed,
    iv: iv,
  );
}

CryptoEncodingValidation validateDecoding({
  required String encoded,
  CryptoDecodeOptions? opts,
}) {
  final deserialized = deserialize(encoded);
  return validateEncoding(CryptoEncodeOptions(
    type: decodeTypeByte(deserialized.type),
    senderPublicKey: deserialized.senderPublicKey != null
        ? hex.encode(deserialized.senderPublicKey!)
        : null,
    receiverPublicKey: opts?.receiverPublicKey,
  ));
}

CryptoEncodingValidation validateEncoding([CryptoEncodeOptions? opts]) {
  final type = opts?.type ?? TYPE_0;
  if (type == TYPE_1) {
    if (opts?.senderPublicKey == null) {
      throw WCException("missing sender public key");
    }
    if (opts?.receiverPublicKey == null) {
      throw WCException("missing receiver public key");
    }
  }
  return CryptoEncodingValidation(
    type: type,
    senderPublicKey: opts?.senderPublicKey,
    receiverPublicKey: opts?.receiverPublicKey,
  );
}

bool isTypeOneEnvelope(CryptoEncodingValidation result) {
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
