import 'package:logger/logger.dart';
import 'package:walletconnect_v2/core/crypto/i_crypto.dart';
import 'package:walletconnect_v2/core/expirer/i_expirer.dart';
import 'package:walletconnect_v2/core/history/models.dart';
import 'package:walletconnect_v2/core/pairing/i_pairing.dart';
import 'package:walletconnect_v2/core/relayer/i_relayer.dart';
import 'package:walletconnect_v2/wc_utils/misc/events/events.dart';
import 'package:walletconnect_v2/wc_utils/misc/heartbeat/i_heart_beat.dart';
import 'package:walletconnect_v2/wc_utils/misc/keyvaluestorage/i_key_value_storage.dart';

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
