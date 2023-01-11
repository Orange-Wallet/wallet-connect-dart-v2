import 'package:logger/logger.dart';
import 'package:wallet_connect/core/crypto/i_crypto.dart';
import 'package:wallet_connect/core/expirer/types.dart';
import 'package:wallet_connect/core/history/types.dart';
import 'package:wallet_connect/core/pairing/types.dart';
import 'package:wallet_connect/core/relayer/i_relayer.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';
import 'package:wallet_connect/wc_utils/misc/heartbeat/types.dart';
import 'package:wallet_connect/wc_utils/misc/keyvaluestorage/types.dart';

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
