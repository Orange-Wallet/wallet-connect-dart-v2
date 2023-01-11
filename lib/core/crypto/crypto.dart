import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:wallet_connect/core/crypto/constants.dart';
import 'package:wallet_connect/core/crypto/i_crypto.dart';
import 'package:wallet_connect/core/crypto/models.dart';
import 'package:wallet_connect/core/i_core.dart';
import 'package:wallet_connect/core/keychain/keychain.dart';
import 'package:wallet_connect/core/keychain/types.dart';
import 'package:wallet_connect/utils/crypto.dart' as utils;
import 'package:wallet_connect/utils/error.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/error.dart';
import 'package:wallet_connect/wc_utils/relay_auth/relay_auth.dart'
    as relay_auth;

class Crypto implements ICrypto {
  @override
  final String name = CRYPTO_CONTEXT;

  @override
  final IKeyChain keychain;

  @override
  final ICore core;

  @override
  final Logger logger;

  Crypto({
    required this.core,
    Logger? logger,
    IKeyChain? keychain,
  })  : logger = logger ?? Logger(),
        keychain = keychain ?? KeyChain(core: core),
        _initialized = false;

  bool _initialized;

  @override
  Future<void> init() async {
    if (!_initialized) {
      await keychain.init();
      _initialized = true;
    }
  }

  @override
  bool hasKeys(tag) {
    _isInitialized();
    return keychain.has(tag);
  }

  @override
  getClientId() async {
    _isInitialized();
    final seed = await _getClientSeed();
    final keyPair = await relay_auth.generateKeyPair(seed);
    final clientId =
        relay_auth.encodeIss(Uint8List.fromList(hex.decode(keyPair.publicKey)));
    return clientId;
  }

  @override
  Future<String> generateKeyPair() async {
    _isInitialized();
    final keyPair = await utils.generateKeyPair();
    return _setPrivateKey(keyPair.publicKey, keyPair.privateKey);
  }

  @override
  Future<String> signJWT(aud) async {
    _isInitialized();
    final seed = await _getClientSeed();
    final keyPair = await relay_auth.generateKeyPair(seed);
    final sub = utils.generateRandomBytes32();
    final ttl = CRYPTO_JWT_TTL;
    final jwt = await relay_auth.signJWT(
      sub: sub,
      aud: aud,
      ttl: ttl,
      keyPair: keyPair,
    );
    return jwt;
  }

  @override
  Future<String> generateSharedKey({
    required String selfPublicKey,
    required String peerPublicKey,
    String? overrideTopic,
  }) async {
    _isInitialized();
    final selfPrivateKey = _getPrivateKey(selfPublicKey);
    final symKey = await utils.deriveSymKey(selfPrivateKey, peerPublicKey);
    return setSymKey(symKey: symKey, overrideTopic: overrideTopic);
  }

  @override
  Future<String> setSymKey(
      {required String symKey, String? overrideTopic}) async {
    _isInitialized();
    final topic = overrideTopic ?? await utils.hashKey(symKey);
    await keychain.set(topic, symKey);
    return topic;
  }

  @override
  Future<void> deleteKeyPair({required String publicKey}) async {
    _isInitialized();
    await keychain.del(publicKey);
  }

  @override
  Future<void> deleteSymKey({required String topic}) async {
    _isInitialized();
    await keychain.del(topic);
  }

  @override
  Future<String> encode({
    required String topic,
    required Object payload,
    CryptoEncodeOptions? opts,
  }) async {
    _isInitialized();
    final params = utils.validateEncoding(opts);
    final message = jsonEncode(payload);
    if (utils.isTypeOneEnvelope(params)) {
      final selfPublicKey = params.senderPublicKey!;
      final peerPublicKey = params.receiverPublicKey!;
      topic = await generateSharedKey(
        selfPublicKey: selfPublicKey,
        peerPublicKey: peerPublicKey,
      );
    }
    final symKey = _getSymKey(topic);
    final result = utils.encrypt(
      type: params.type,
      symKey: symKey,
      message: message,
      senderPublicKey: params.senderPublicKey,
    );
    return result;
  }

  @override
  Future<dynamic> decode({
    required String topic,
    required String encoded,
    CryptoDecodeOptions? opts,
  }) async {
    _isInitialized();
    final params = utils.validateDecoding(encoded: encoded, opts: opts);
    if (utils.isTypeOneEnvelope(params)) {
      final selfPublicKey = params.receiverPublicKey!;
      final peerPublicKey = params.senderPublicKey!;
      topic = await generateSharedKey(
        selfPublicKey: selfPublicKey,
        peerPublicKey: peerPublicKey,
      );
    }
    final symKey = _getSymKey(topic);
    final message = await utils.decrypt(symKey: symKey, encoded: encoded);
    final payload = jsonDecode(message);
    return payload;
  }

  @override
  int getPayloadType(String encoded) {
    final deserialized = utils.deserialize(encoded);
    return utils.decodeTypeByte(deserialized.type);
  }

  // ---------- Private ----------------------------------------------- //

  Future<String> _setPrivateKey(String publicKey, String privateKey) async {
    await keychain.set(publicKey, privateKey);
    return publicKey;
  }

  String _getPrivateKey(String publicKey) {
    final privateKey = keychain.get(publicKey);
    return privateKey;
  }

  Future<Uint8List> _getClientSeed() async {
    String seed = "";
    try {
      seed = keychain.get(CRYPTO_CLIENT_SEED);
    } catch (e) {
      seed = utils.generateRandomBytes32();
      await keychain.set(CRYPTO_CLIENT_SEED, seed);
    }
    return Uint8List.fromList(hex.decode(seed));
  }

  String _getSymKey(String topic) {
    final symKey = keychain.get(topic);
    return symKey;
  }

  void _isInitialized() {
    if (!_initialized) {
      final error =
          getInternalError(InternalErrorKey.NOT_INITIALIZED, context: name);
      throw WCException(error.message);
    }
  }
}
