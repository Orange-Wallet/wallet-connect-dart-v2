import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

@JsonSerializable()
class IridiumJWTHeader {
  final String alg;
  final String typ;

  IridiumJWTHeader({
    this.alg = "EdDSA",
    this.typ = "JWT",
  });

  factory IridiumJWTHeader.fromJson(Map<String, dynamic> json) =>
      _$IridiumJWTHeaderFromJson(json);

  Map<String, dynamic> toJson() => _$IridiumJWTHeaderToJson(this);
}

@JsonSerializable()
class IridiumJWTPayload {
  final String iss;
  final String sub;
  final String aud;
  final int iat;
  final int exp;

  IridiumJWTPayload({
    required this.iss,
    required this.sub,
    required this.aud,
    required this.iat,
    required this.exp,
  });

  factory IridiumJWTPayload.fromJson(Map<String, dynamic> json) =>
      _$IridiumJWTPayloadFromJson(json);

  Map<String, dynamic> toJson() => _$IridiumJWTPayloadToJson(this);
}

class IridiumJWTData {
  final IridiumJWTHeader header;
  final IridiumJWTPayload payload;

  IridiumJWTData({
    required this.header,
    required this.payload,
  });
}

class RelayAuthKeyPair {
  final List<int> privateKeyBytes;
  final String privateKey;
  final List<int> publicKeyBytes;
  final String publicKey;

  RelayAuthKeyPair({
    required this.privateKeyBytes,
    required this.privateKey,
    required this.publicKeyBytes,
    required this.publicKey,
  });
}

class IridiumJWTSigned extends IridiumJWTData {
  final Uint8List signature;

  IridiumJWTSigned({
    required IridiumJWTHeader header,
    required IridiumJWTPayload payload,
    required this.signature,
  }) : super(header: header, payload: payload);
}

class IridiumJWTDecoded extends IridiumJWTSigned {
  final Uint8List data;

  IridiumJWTDecoded({
    required IridiumJWTHeader header,
    required IridiumJWTPayload payload,
    required Uint8List signature,
    required this.data,
  }) : super(
          header: header,
          payload: payload,
          signature: signature,
        );
}
