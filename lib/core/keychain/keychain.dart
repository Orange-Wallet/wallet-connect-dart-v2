import 'package:logger/logger.dart';
import 'package:wallet_connect/core/constants.dart';
import 'package:wallet_connect/core/i_core.dart';
import 'package:wallet_connect/core/keychain/constants.dart';
import 'package:wallet_connect/core/keychain/types.dart';
import 'package:wallet_connect/utils/error.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/error.dart';

class KeyChain implements IKeyChain {
  @override
  Map<String, String> keychain;

  @override
  final name = KEYCHAIN_CONTEXT;

  final version = KEYCHAIN_STORAGE_VERSION;

  bool _initialized = false;
  final _storagePrefix = CORE_STORAGE_PREFIX;

  @override
  final ICore core;

  @override
  final Logger logger;

  KeyChain({
    required this.core,
    Logger? logger,
  })  : logger = logger ?? Logger(),
        keychain = {};

  @override
  init() async {
    if (!_initialized) {
      final keychain = await _getKeyChain();
      if (keychain != null) {
        this.keychain = keychain;
      }
      _initialized = true;
    }
  }

  String get storageKey => '$_storagePrefix$version//$name';

  @override
  has(String tag) {
    _isInitialized();
    return keychain.containsKey(tag);
  }

  @override
  set(String tag, String key) async {
    _isInitialized();
    keychain[tag] = key;
    await _persist();
  }

  @override
  get(tag) {
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
  del(tag) async {
    _isInitialized();
    keychain.remove(tag);
    await _persist();
  }

  // ---------- Private ----------------------------------------------- //

  Future _setKeyChain(Map<String, String> keychain) =>
      core.storage.setItem<Map<String, String>>(storageKey, keychain);

  Future _getKeyChain() async {
    final keychain =
        await core.storage.getItem<Map<String, String>>(storageKey);
    return keychain;
  }

  _persist() async {
    await _setKeyChain(keychain);
  }

  _isInitialized() {
    if (!_initialized) {
      final error =
          getInternalError(InternalErrorKey.NOT_INITIALIZED, context: name);
      throw WCException(error.message);
    }
  }
}
