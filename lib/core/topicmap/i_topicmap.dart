abstract class ISubscriberTopicMap {
  List<String> get topics;

  void set(String topic, String id);

  List<String> get(String topic);

  bool exists(String topic, String id);

  void delete({required String topic, String? id});

  void clear();
}
