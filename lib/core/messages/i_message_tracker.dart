import 'package:logger/logger.dart';
import 'package:wallet_connect_dart_v2/core/i_core.dart';

typedef MessageRecord = Map<String, String>;

abstract class IMessageTracker {
  Map<String, MessageRecord> get messages;

  String get name;

  ICore get core;

  Logger get logger;

  Future<void> init();

  Future<String> set(String topic, String message);

  MessageRecord get(String topic);

  Future<bool> has(String topic, String message);

  Future<void> del(String topic);
}
