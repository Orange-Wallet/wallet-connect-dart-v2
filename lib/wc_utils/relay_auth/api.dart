import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';
import 'package:flutter/foundation.dart';
import 'package:wallet_connect/utils/crypto.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/error.dart';
import 'package:wallet_connect/wc_utils/relay_auth/constants.dart';
import 'package:wallet_connect/wc_utils/relay_auth/relay_auth.dart';
import 'package:wallet_connect/wc_utils/relay_auth/types.dart';

Future<RelayAuthKeyPair> generateKeyPair([Uint8List? seed]) async {
  seed ??= Uint8List.fromList(randomBytes(KEY_PAIR_SEED_LENGTH));
  final keyPair = await DartEd25519().newKeyPairFromSeed(seed);
  return RelayAuthKeyPair(
    privateKey: hex.encode((await keyPair.extractPrivateKeyBytes())),
    publicKey: hex.encode((await keyPair.extractPublicKey()).bytes),
  );
}

signJWT({
  required String sub,
  required String aud,
  required int ttl,
  required RelayAuthKeyPair keyPair,
  int? iat,
}) async {
  iat ??= (DateTime.now().millisecondsSinceEpoch ~/ 1000);
  final header = IridiumJWTHeader(alg: JWT_IRIDIUM_ALG, typ: JWT_IRIDIUM_TYP);
  final iss = encodeIss(Uint8List.fromList(hex.decode(keyPair.publicKey)));
  final exp = iat + ttl;
  final payload =
      IridiumJWTPayload(iss: iss, sub: sub, aud: aud, iat: iat, exp: exp);
  final data = encodeData(IridiumJWTData(header: header, payload: payload));

  const type = KeyPairType.ed25519;
  final privateKeyBytes = hex.decode(keyPair.privateKey);
  final publicKeyBytes = hex.decode(keyPair.publicKey);
  final publicKey = SimplePublicKey(publicKeyBytes, type: type);
  final simpleKeyPair =
      SimpleKeyPairData(privateKeyBytes, publicKey: publicKey, type: type);
  final signature = Uint8List.fromList(
      (await DartEd25519().sign(data, keyPair: simpleKeyPair)).bytes);
  return encodeJWT(IridiumJWTSigned(
    header: header,
    payload: payload,
    signature: signature,
  ));
}

Future<bool> verifyJWT(String jwt) {
  final decoded = decodeJWT(jwt);
  if (decoded.header.alg != JWT_IRIDIUM_ALG ||
      decoded.header.typ != JWT_IRIDIUM_TYP) {
    throw WCException("JWT must use EdDSA algorithm");
  }
  final publicKey = decodeIss(decoded.payload.iss);
  const type = KeyPairType.ed25519;
  final signature = Signature(
    decoded.signature,
    publicKey: SimplePublicKey(publicKey, type: type),
  );
  return DartEd25519().verify(decoded.data, signature: signature);
}
