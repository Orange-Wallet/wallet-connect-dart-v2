import 'package:logger/logger.dart';
import 'package:wallet_connect_dart_v2/core/i_core.dart';
import 'package:wallet_connect_dart_v2/wc_utils/jsonrpc/models/models.dart';

typedef StoreObjToJson<V> = dynamic Function(V);

typedef StoreObjFromJson<V> = V Function(dynamic);

abstract class IStore<K, V> {
  Map<K, V> get map;

  int get length;

  List<K> get keys;

  List<V> get values;

  ICore get core;

  Logger get logger;

  String get name;

  StoreObjToJson<V> get toJson;

  StoreObjFromJson<V> get fromJson;

  String? get storagePrefix;

  Future<void> init();

  Future<void> set(K key, V value);

  V get(K key);

  List<V> getAll([V? filter]);

  Future<void> update(K key, V Function(V V) update);

  Future<void> delete(K key, ErrorResponse reason);
}
