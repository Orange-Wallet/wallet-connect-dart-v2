import 'package:wallet_connect/core/subscriber/types.dart';

class SubscriberTopicMap implements ISubscriberTopicMap {
  final Map<String, List<String>> map;

  SubscriberTopicMap() : map = {};

  @override
  List<String> get topics => map.keys.toList();

  @override
  void set(String topic, String id) {
    final ids = get(topic);
    if (exists(topic, id)) return;
    map[topic] = [...ids, id];
  }

  @override
  List<String> get(String topic) {
    final ids = map[topic];
    return ids ?? [];
  }

  @override
  bool exists(String topic, String id) {
    final ids = get(topic);
    return ids.contains(id);
  }

  @override
  void delete({required String topic, String? id}) {
    if (id == null) {
      map.remove(topic);
      return;
    }
    if (!map.containsKey(topic)) return;
    final ids = get(topic);
    if (!exists(topic, id)) return;
    final remaining = ids.where((x) => x != id).toList();
    if (remaining.isEmpty) {
      map.remove(topic);
      return;
    }
    map[topic] = remaining;
  }

  @override
  void clear() {
    map.clear();
  }
}
