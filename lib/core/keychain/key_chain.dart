import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:wallet_connect_dart_v2/core/constants.dart';
import 'package:wallet_connect_dart_v2/core/i_core.dart';
import 'package:wallet_connect_dart_v2/core/keychain/constants.dart';
import 'package:wallet_connect_dart_v2/core/keychain/i_key_chain.dart';
import 'package:wallet_connect_dart_v2/utils/error.dart';
import 'package:wallet_connect_dart_v2/wc_utils/jsonrpc/utils/error.dart';

class KeyChain implements IKeyChain {
  @override
  Map<String, String> keychain;

  @override
  final name = KEYCHAIN_CONTEXT;

  final version = KEYCHAIN_STORAGE_VERSION;

  final storagePrefix = CORE_STORAGE_PREFIX;

  @override
  final ICore core;

  @override
  final Logger logger;

  bool _initialized = false;

  KeyChain({
    required this.core,
    Logger? logger,
  })  : logger = logger ?? Logger(),
        keychain = {};

  @override
  Future<void> init() async {
    if (!_initialized) {
      final keychain = await _getKeyChain();
      if (keychain != null) {
        this.keychain = keychain;
      }
      _initialized = true;
    }
  }

  String get storageKey => '$storagePrefix$version//$name';

  @override
  bool has(String tag) {
    _isInitialized();
    return keychain.containsKey(tag);
  }

  @override
  Future<void> set(String tag, String key) async {
    _isInitialized();
    keychain[tag] = key;
    await _persist();
  }

  @override
  String get(String tag) {
    _isInitialized();
    final key = keychain[tag];
    if (key == null) {
      final error = getInternalError(InternalErrorKey.NO_MATCHING_KEY,
          context: '$name: $tag');
      throw WCException(error.message);
    }
    return key;
  }

  @override
  Future<void> del(String tag) async {
    _isInitialized();
    keychain.remove(tag);
    await _persist();
  }

  // ---------- Private ----------------------------------------------- //

  Future _setKeyChain(Map<String, String> keychain) =>
      core.storage.setItem(storageKey, jsonEncode(keychain));

  Future<Map<String, String>?> _getKeyChain() async {
    final keychain = await core.storage.getItem(storageKey);
    return keychain == null
        ? null
        : Map<String, String>.from(jsonDecode(keychain));
  }

  Future<void> _persist() async {
    await _setKeyChain(keychain);
  }

  void _isInitialized() {
    if (!_initialized) {
      final error =
          getInternalError(InternalErrorKey.NOT_INITIALIZED, context: name);
      throw WCException(error.message);
    }
  }
}
