import 'package:logger/logger.dart';
import 'package:wallet_connect/core/core/types.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/types.dart';

abstract class IStore<K, V> {
  Map<K, V> get map;

  int get length;

  List<K> get keys;

  List<V> get values;

  ICore get core;

  Logger get logger;

  String get name;

  String? get storagePrefix;

  Future<void> init();

  Future<void> set(K key, V value);

  V get(K key);

  List<V> getAll([V? filter]);

  Future<void> update(K key, V Function(V V) update);

  Future<void> delete(K key, ErrorResponse reason);
}
