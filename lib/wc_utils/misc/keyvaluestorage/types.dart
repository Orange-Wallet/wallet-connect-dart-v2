abstract class IKeyValueStorage {
  Future<List<String>> getKeys();
  Future<List<MapEntry<String, T>>> getEntries<T>();
  Future<T?> getItem<T>(String key);
  Future<void> setItem<T>(String key, T value);
  Future<void> removeItem(String key);
}
