abstract class IKeyValueStorage {
  Future<List<String>> getKeys();

  Future<List<MapEntry<String, T>>> getEntries<T>();

  Future<dynamic> getItem(String key);

  Future<void> setItem(String key, dynamic value);

  Future<void> removeItem(String key);
}
