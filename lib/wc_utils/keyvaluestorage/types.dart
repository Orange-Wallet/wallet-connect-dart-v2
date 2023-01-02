class KeyValueStorageOptions {
  final String? database;
  final String? table;

  KeyValueStorageOptions({this.database, this.table});
}

abstract class IKeyValueStorage {
  Future<List<String>> getKeys();
  Map<String, T> getEntries<T>();
  Future<T?> getItem<T>(String key);
  Future<void> setItem<T>(String key, T value);
  Future<void> removeItem(String key);
}
