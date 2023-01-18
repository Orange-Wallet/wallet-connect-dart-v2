import 'dart:convert';

import 'package:bs58/bs58.dart';
import 'package:flutter/foundation.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/error.dart';
import 'package:wallet_connect/wc_utils/relay_auth/base64.dart';
import 'package:wallet_connect/wc_utils/relay_auth/constants.dart';
import 'package:wallet_connect/wc_utils/relay_auth/models.dart';

// ---------- JSON ----------------------------------------------- //

dynamic decodeJSON(String str) {
  return jsonDecode(utf8.decode(B64urlEncRfc7515.decode(str)));
}

String encodeJSON(Object val) {
  return B64urlEncRfc7515.encode(utf8.encode(jsonEncode(val)));
}

// ---------- Issuer ----------------------------------------------- //

String encodeIss(Uint8List publicKey) {
  final header = base58.decode(MULTICODEC_ED25519_HEADER);
  final multicodec = MULTICODEC_ED25519_BASE +
      base58.encode(Uint8List.fromList([...header, ...publicKey]));
  return [DID_PREFIX, DID_METHOD, multicodec].join(DID_DELIMITER);
}

Uint8List decodeIss(String issuer) {
  final split = issuer.split(DID_DELIMITER);
  final prefix = split[0];
  final method = split[1];
  final multicodec = split[2];
  if (prefix != DID_PREFIX || method != DID_METHOD) {
    throw WCException('Issuer must be a DID with method "key"');
  }
  final base = multicodec.substring(0, 1);
  if (base != MULTICODEC_ED25519_BASE) {
    throw WCException('Issuer must be a key in mulicodec format');
  }
  final bytes = base58.decode(multicodec.substring(1));
  final type = base58.encode(bytes.sublist(0, 2));
  if (type != MULTICODEC_ED25519_HEADER) {
    throw WCException('Issuer must be a public key with type "Ed25519"');
  }
  final publicKey = bytes.sublist(2);
  if (publicKey.length != MULTICODEC_ED25519_LENGTH) {
    throw WCException('Issuer must be a public key with length 32 bytes');
  }
  return publicKey;
}

// ---------- Signature ----------------------------------------------- //

String encodeSig(Uint8List bytes) {
  return B64urlEncRfc7515.encode(bytes);
}

Uint8List decodeSig(String encoded) {
  return Uint8List.fromList(B64urlEncRfc7515.decode(encoded));
}

// ---------- Data ----------------------------------------------- //

Uint8List encodeData(IridiumJWTData params) {
  return Uint8List.fromList(utf8.encode([
    encodeJSON(params.header.toJson()),
    encodeJSON(params.payload.toJson())
  ].join(JWT_DELIMITER)));
}

IridiumJWTData decodeData(Uint8List data) {
  final params = utf8.decode(data).split(JWT_DELIMITER);
  final header = decodeJSON(params[0]);
  final payload = decodeJSON(params[1]);
  return IridiumJWTData(header: header, payload: payload);
}

// ---------- JWT ----------------------------------------------- //

String encodeJWT(IridiumJWTSigned params) {
  return [
    encodeJSON(params.header.toJson()),
    encodeJSON(params.payload.toJson()),
    encodeSig(params.signature),
  ].join(JWT_DELIMITER);
}

IridiumJWTDecoded decodeJWT(String jwt) {
  final params = jwt.split(JWT_DELIMITER);
  final header = IridiumJWTHeader.fromJson(decodeJSON(params[0]));
  final payload = IridiumJWTPayload.fromJson(decodeJSON(params[1]));
  final signature = decodeSig(params[2]);
  final data =
      Uint8List.fromList(utf8.encode(params.sublist(0, 2).join(JWT_DELIMITER)));
  return IridiumJWTDecoded(
    header: header,
    payload: payload,
    signature: signature,
    data: data,
  );
}
