import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

import 'package:wallet_connect/core/core/constants.dart';
import 'package:wallet_connect/core/core/types.dart';
import 'package:wallet_connect/core/store/constants.dart';
import 'package:wallet_connect/core/store/types.dart';
import 'package:wallet_connect/sign/sign-client/proposal/types.dart';
import 'package:wallet_connect/sign/sign-client/session/types.dart';
import 'package:wallet_connect/utils/error.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/error.dart';

class Store<K, V> implements IStore<K, V> {
  @override
  final Map<K, V> map;
  final version = STORE_STORAGE_VERSION;

  List<V> cached = [];
  bool _initialized = false;

  /**
   * Regenerates the value key to retrieve it from cache
   */
  // private getKey: ((data: V) => K) | undefined;
  @override
  final String storagePrefix;

  @override
  final ICore core;

  @override
  final Logger logger;

  @override
  final String name;

  @override
  final dynamic Function(V) toJson;

  @override
  final V Function(Object?) fromJson;

  /**
   * @param {ICore} core Core
   * @param {Logger} logger Logger
   * @param {string} name Store's name
   * @param {Store<K, V>["getKey"]} getKey Regenerates the value key to retrieve it from cache
   * @param {string} storagePrefix Prefixes value keys
   */
  Store({
    required this.core,
    Logger? logger,
    required this.name,
    String? storagePrefix,
    required this.fromJson,
    required this.toJson,
  })  : logger = logger ?? Logger(),
        storagePrefix = storagePrefix ?? CORE_STORAGE_PREFIX,
        map = {};

  @override
  init() async {
    if (!_initialized) {
      logger.i('Initialized');
      await _restore();

      cached.forEach((value) {
        if (value is ProposalTypesStruct &&
            (value as ProposalTypesStruct).proposer.publicKey != null) {
          map[(value as ProposalTypesStruct).id as K] = value;
        } else if (value is SessionTypesStruct &&
            (value as SessionTypesStruct).topic != null) {
          map[(value as SessionTypesStruct).topic as K] = value;
        }
        // else if (getKey && value != null ) {
        //   map.set(getKey(value), value);
        // }
      });

      cached.clear();
      _initialized = true;
    }
  }

  String get storageKey => '$storagePrefix$version//$name';

  @override
  get length => map.length;

  @override
  get keys => map.keys.toList();

  @override
  get values => map.values.toList();

  @override
  set(K key, V value) async {
    _isInitialized();
    // if (map.containsKey(key)) {
    // TODO: Might MF
    //   await update(key, value);
    // } else {
    logger.d('Setting value');
    logger.i({'type': "method", 'method': "set", 'key': key, 'value': value});
    map[key] = value;
    await _persist();
    // }
  }

  @override
  V get(K key) {
    _isInitialized();
    logger.d('Getting value');
    logger.i({'type': "method", 'method': "get", 'key': key});
    final value = _getData(key);
    return value;
  }

  @override
  List<V> getAll([V? filter]) {
    _isInitialized();
    if (filter == null) return values;

    return values.where((value) => value == filter).toList();
  }

  @override
  update(key, V Function(V V) update) async {
    _isInitialized();
    final value = update(_getData(key));
    logger.d('Updating value');
    logger.i(
        {'type': "method", 'method': "update", 'key': key, 'update': update});
    map[key] = value;
    await _persist();
  }

  @override
  delete(key, reason) async {
    _isInitialized();
    if (!map.containsKey(key)) return;
    logger.d('Deleting value');
    logger.i(
        {'type': "method", 'method': "delete", 'key': key, 'reason': reason});
    map.remove(key);
    await _persist();
  }

  // ---------- Private ----------------------------------------------- //

  void _setDataStore(List<dynamic> values) async {
    await core.storage.setItem<List<dynamic>>(storageKey, values);
  }

  Future<List<dynamic>?> _getDataStore() async {
    final value = await core.storage.getItem<List<dynamic>>(storageKey);
    return value;
  }

  V _getData(K key) {
    final value = map[key];
    if (value == null) {
      final error = getInternalError(
        InternalErrorKey.NO_MATCHING_KEY,
        context: '${name}: ${key}',
      );
      logger.e(error.message);
      throw WCException(error.message);
    }
    return value;
  }

  _persist() {
    _setDataStore(values.map((e) => toJson(e)).toList());
  }

  _restore() async {
    try {
      final persisted = await _getDataStore();
      if (persisted?.isEmpty ?? true) return;
      if (map.isNotEmpty) {
        final error = getInternalError(
          InternalErrorKey.RESTORE_WILL_OVERRIDE,
          context: name,
        );
        logger.e(error.message);
        throw WCException(error.message);
      }
      cached = persisted?.map((e) => fromJson(e)).toList() ?? [];
      logger.d('Successfully Restored value for ${name}');
      logger.i({'type': "method", 'method': "restore", 'value': values});
    } catch (e) {
      logger.d('Failed to Restore value for ${name}');
      logger.e(e.toString());
    }
  }

  _isInitialized() {
    if (!_initialized) {
      final error = getInternalError(
        InternalErrorKey.NOT_INITIALIZED,
        context: name,
      );
      throw WCException(error.message);
    }
  }
}
