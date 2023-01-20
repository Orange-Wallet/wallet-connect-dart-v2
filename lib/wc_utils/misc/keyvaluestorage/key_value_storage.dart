import 'dart:async';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wallet_connect/core/expirer/models.dart';
import 'package:wallet_connect/core/history/models.dart';
import 'package:wallet_connect/core/models/app_metadata.dart';
import 'package:wallet_connect/core/pairing/models.dart';
import 'package:wallet_connect/core/relayer/models.dart';
import 'package:wallet_connect/core/subscriber/models.dart';
import 'package:wallet_connect/sign/sign-client/jsonrpc/models.dart';
import 'package:wallet_connect/sign/sign-client/pending_request/models.dart';
import 'package:wallet_connect/sign/sign-client/proposal/models.dart';
import 'package:wallet_connect/sign/sign-client/session/models.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/models/models.dart';
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

        Hive.registerAdapter(JsonRpcRecordAdapter(), override: true);
        Hive.registerAdapter(ExpirerExpirationAdapter(), override: true);
        Hive.registerAdapter(RelayerProtocolOptionsAdapter(), override: true);
        Hive.registerAdapter(AppMetadataAdapter(), override: true);
        Hive.registerAdapter(PairingStructAdapter(), override: true);
        Hive.registerAdapter(SubscriberActiveAdapter(), override: true);
        Hive.registerAdapter(RpcSessionRequestParamsAdapter(), override: true);
        Hive.registerAdapter(PendingRequestStructAdapter(), override: true);
        Hive.registerAdapter(ProposalBaseRequiredNamespaceAdapter(),
            override: true);
        Hive.registerAdapter(ProposalRequiredNamespaceAdapter(),
            override: true);
        Hive.registerAdapter(ProposalProposerAdapter(), override: true);
        Hive.registerAdapter(ProposalRequestStructAdapter(), override: true);
        Hive.registerAdapter(ProposalStructAdapter(), override: true);
        Hive.registerAdapter(SessionBaseNamespaceAdapter(), override: true);
        Hive.registerAdapter(SessionNamespaceAdapter(), override: true);
        Hive.registerAdapter(SessionPublicKeyMetadataAdapter(), override: true);
        Hive.registerAdapter(SessionStructAdapter(), override: true);
        Hive.registerAdapter(RequestArgumentsAdapter(), override: true);

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
    // final item = _data[key] is Map ? Map.from(_data[key]) : _data[key] as T?;
    return _data[key];
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
}
