import 'dart:async';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wallet_connect/wc_utils/misc/keyvaluestorage/types.dart';

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
  Future<T?> getItem<T>(String key) async {
    await _initilization();
    final item = _data[key] as T?;
    return item;
  }

  @override
  Future<void> setItem<T>(String key, T value) async {
    await _initilization();
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
}
