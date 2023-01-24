import 'package:logger/logger.dart';
import 'package:wallet_connect_v2/core/expirer/models.dart';
import 'package:wallet_connect_v2/core/i_core.dart';
import 'package:wallet_connect_v2/wc_utils/misc/events/events.dart';

abstract class IExpirer with IEvents {
  String get name;

  int get length;

  List<String> get keys;

  List<ExpirerExpiration> get values;

  ICore get core;

  Logger get logger;

  Future<void> init();

  bool has(dynamic key);

  void set(dynamic key, int expiry);

  ExpirerExpiration get(dynamic key);

  void del(dynamic key);
}
