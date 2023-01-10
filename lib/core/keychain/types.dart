import 'package:logger/logger.dart';
import 'package:wallet_connect/core/i_core.dart';

abstract class IKeyChain {
  Map<String, String> get keychain;

  String get name;

  ICore get core;

  Logger get logger;

  Future<void> init();

  bool has(String tag);

  Future<void> set(String tag, String key);

  get(String tag);

  Future<void> del(String tag);
}
