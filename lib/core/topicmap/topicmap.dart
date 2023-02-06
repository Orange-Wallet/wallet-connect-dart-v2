import 'package:wallet_connect_dart_v2/core/topicmap/i_topicmap.dart';

class SubscriberTopicMap implements ISubscriberTopicMap {
  final Map<String, List<String>> _map;

  SubscriberTopicMap() : _map = {};

  @override
  List<String> get topics => _map.keys.toList();

  @override
  void set(String topic, String id) {
    final ids = get(topic);
    if (exists(topic, id)) return;
    _map[topic] = [...ids, id];
  }

  @override
  List<String> get(String topic) {
    final ids = _map[topic];
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
      _map.remove(topic);
      return;
    }
    if (!_map.containsKey(topic)) return;
    final ids = get(topic);
    if (!exists(topic, id)) return;
    final remaining = ids.where((x) => x != id).toList();
    if (remaining.isEmpty) {
      _map.remove(topic);
      return;
    }
    _map[topic] = remaining;
  }

  @override
  void clear() {
    _map.clear();
  }
}
