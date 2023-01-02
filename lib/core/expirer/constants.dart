const EXPIRER_CONTEXT = "expirer";

class ExpirerEvents {
  ExpirerEvents._();

  static const String created = "expirer_created";
  static const String deleted = "expirer_deleted";
  static const String expired = "expirer_expired";
  static const String sync = "expirer_sync";
}

const EXPIRER_STORAGE_VERSION = "0.3";

const EXPIRER_DEFAULT_TTL = 1 * 24 * 60 * 60; // 1day in secs
