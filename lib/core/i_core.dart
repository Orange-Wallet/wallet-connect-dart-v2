import 'package:logger/logger.dart';
import 'package:wallet_connect/core/crypto/i_crypto.dart';
import 'package:wallet_connect/core/expirer/i_expirer.dart';
import 'package:wallet_connect/core/history/models.dart';
import 'package:wallet_connect/core/pairing/i_pairing.dart';
import 'package:wallet_connect/core/relayer/i_relayer.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';
import 'package:wallet_connect/wc_utils/misc/heartbeat/i_heart_beat.dart';
import 'package:wallet_connect/wc_utils/misc/keyvaluestorage/i_key_value_storage.dart';

abstract class ICore with IEvents {
  String get protocol;

  int get version;

  Logger get logger;

  IHeartBeat get heartbeat;

  ICrypto get crypto;

  IRelayer get relayer;

  IKeyValueStorage get storage;

  IJsonRpcHistory get history;

  IExpirer get expirer;

  IPairing get pairing;

  String get name;

  String? get projectId;

  String? get relayUrl;

  Future<void> start();
}
