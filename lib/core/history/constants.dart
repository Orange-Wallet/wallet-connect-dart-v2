class HistoryEvents {
  HistoryEvents._();

  static const String created = "history_created";
  static const String updated = "history_updated";
  static const String deleted = "history_deleted";
  static const String sync = "history_sync";
}

const HISTORY_CONTEXT = "history";

const HISTORY_STORAGE_VERSION = "0.3";
