const CORE_PROTOCOL = "wc";
const CORE_VERSION = 2;
const CORE_CONTEXT = "core";

const CORE_STORAGE_PREFIX = '$CORE_PROTOCOL@$CORE_VERSION:$CORE_CONTEXT:';

class CoreDefault {
  CoreDefault._();

  static const String name = CORE_CONTEXT;
  static const String logger = "error";
}

class CoreStorageOptions {
  CoreStorageOptions._();

  static const String database = ":memory:";
}
