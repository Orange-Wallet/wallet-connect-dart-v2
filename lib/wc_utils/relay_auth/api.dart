import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;
import 'package:walletconnect_v2/wc_utils/jsonrpc/utils/error.dart';
import 'package:walletconnect_v2/wc_utils/relay_auth/constants.dart';
import 'package:walletconnect_v2/wc_utils/relay_auth/models.dart';
import 'package:walletconnect_v2/wc_utils/relay_auth/relay_auth.dart';

Future<RelayAuthKeyPair> generateKeyPair([Uint8List? seed]) async {
  // seed ??= Uint8List.fromList(randomBytes(KEY_PAIR_SEED_LENGTH));
  ed.PrivateKey privateKey;
  ed.PublicKey publicKey;
  if (seed == null) {
    final keyPair = ed.generateKey();
    privateKey = keyPair.privateKey;
    publicKey = keyPair.publicKey;
  } else {
    privateKey = ed.newKeyFromSeed(seed);
    publicKey = ed.public(privateKey);
  }

  return RelayAuthKeyPair(
    privateKeyBytes: privateKey.bytes,
    privateKey: hex.encode(privateKey.bytes),
    publicKeyBytes: publicKey.bytes,
    publicKey: hex.encode(publicKey.bytes),
  );

  // NW
  // final kP = await bc.Ed25519().newKeyPair();
  // final pvtKey = await kP.extractPrivateKeyBytes();
  // final pbcKey = (await kP.extractPublicKey()).bytes;
  // return RelayAuthKeyPair(
  //   privateKeyBytes: pvtKey,
  //   privateKey: hex.encode(pvtKey),
  //   publicKeyBytes: pbcKey,
  //   publicKey: hex.encode(pbcKey),
  // );
}

Future<String> signJWT({
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

  // const type = KeyPairType.ed25519;
  // final privateKeyBytes = hex.decode(keyPair.privateKey);
  // final publicKeyBytes = hex.decode(keyPair.publicKey);
  // final publicKey = SimplePublicKey(publicKeyBytes, type: type);
  // final simpleKeyPair =
  //     SimpleKeyPairData(privateKeyBytes, publicKey: publicKey, type: type);
  final signature =
      ed.sign(ed.PrivateKey(hex.decode(keyPair.privateKey)), data);
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
  // const type = KeyPairType.ed25519;
  // final signature = Signature(
  //   decoded.signature,
  //   publicKey: SimplePublicKey(publicKey, type: type),
  // );
  return Future.value(
      ed.verify(ed.PublicKey(publicKey), decoded.data, decoded.signature));
}
