abstract class IStore<K, V> {
  Map<K, V> map;

  String context;

  int length;

  List<K> keys;

  List<V> values;

  IStore({
    ICore core,
    Logger logger,
    String name,
    String? storagePrefix,
  });

  Future<void> init();

  Future<void> set(K key, V value);

  V get(K key);

  List<V> getAll(V? filter);

  Future<void> update(K key, V update);

  Future<void> delete(K key, ErrorResponse reason);
}
