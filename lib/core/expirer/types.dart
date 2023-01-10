import 'package:logger/logger.dart';
import 'package:wallet_connect/core/i_core.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';

class ExpirerTypesExpiration {
  final String target;
  final int expiry;

  ExpirerTypesExpiration({
    required this.target,
    required this.expiry,
  });
}

class ExpirerTypesCreated {
  final String target;
  final ExpirerTypesExpiration expiration;

  ExpirerTypesCreated({
    required this.target,
    required this.expiration,
  });
}

class ExpirerTypesDeleted {
  final String target;
  final ExpirerTypesExpiration expiration;

  ExpirerTypesDeleted({
    required this.target,
    required this.expiration,
  });
}

class ExpirerTypesExpired {
  final String target;
  final ExpirerTypesExpiration expiration;

  ExpirerTypesExpired({
    required this.target,
    required this.expiration,
  });
}

abstract class IExpirer with IEvents {
  String get name;

  int get length;

  List<String> get keys;

  List<ExpirerTypesExpiration> get values;

  ICore get core;

  Logger get logger;

  Future<void> init();

  bool has(String key);

  void set(String key, int expiry);

  ExpirerTypesExpiration get(String key);

  void del(String key);
}
