import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:wallet_connect/wc_utils/misc/keyvaluestorage/i_key_value_storage.dart';

const DB_NAME = "walletconnect.db";

class KeyValueStorage implements IKeyValueStorage {
  final String _dbName;
  bool _initialized = false;
  bool _inMemory = false;
  late Box<dynamic> _box;
  StreamSubscription? _boxSubscription;
  late Map<String, dynamic> _data;

  KeyValueStorage({String? database}) : _dbName = database ?? DB_NAME {
    // flag it so we don't manually save to file
    if (database == ":memory:") {
      _inMemory = true;
    }
    _data = {};

    _databaseInitialize();
  }

  Future<void> _databaseInitialize() async {
    try {
      if (!_inMemory) {
        await Hive.initFlutter();

        _box = await Hive.openBox(_dbName);
        _box.keys.forEach((key) {
          _data[key] = _box.get(key);
        });
        _boxSubscription?.cancel();
        _boxSubscription = _box.watch().listen((event) {
          if (event.deleted) {
            _data.remove(event.key);
          } else {
            _data[event.key] = event.value;
          }
        });
      }
      _initialized = true;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<String>> getKeys() async {
    await _initilization();
    return _data.keys.toList();
  }

  @override
  Future<List<MapEntry<String, T>>> getEntries<T>() async {
    await _initilization();
    return _data.entries
        .where((element) => element.value is T)
        .map((e) => e as MapEntry<String, T>)
        .toList();
  }

  @override
  Future<dynamic> getItem(String key) async {
    await _initilization();
    // log('GET_ITEM: $key ${_data[key].runtimeType}\n${_data[key]}');
    // final item = _data[key] is List
    //     ? _data[key].map((e) => e is Map ? _dynamicToMap(e) : e).toList()
    //     : _data[key];
    return _dynamicToMap(_data[key]);
  }

  @override
  Future<void> setItem(String key, dynamic value) async {
    await _initilization();
    // log('SET_ITEM: $key $value');
    if (_inMemory) {
      _data[key] = value;
    } else {
      _box.put(key, value);
    }
  }

  @override
  Future<void> removeItem(String key) async {
    await _initilization();
    if (_inMemory) {
      _data.remove(key);
    } else {
      _box.delete(key);
    }
  }

  Future<void> _initilization() async {
    if (_initialized) {
      return;
    } else {
      await _databaseInitialize();
    }
  }

  // Convert Map<dynamic, dynamic> to Map<String, dynamic>
  dynamic _dynamicToMap(dynamic map) {
    if (map is List) {
      return map.map((e) => _dynamicToMap(e)).toList();
    } else if (map is Map) {
      return map.map((k, v) => MapEntry(k.toString(), _dynamicToMap(v)));
    } else {
      return map;
    }
  }
}
