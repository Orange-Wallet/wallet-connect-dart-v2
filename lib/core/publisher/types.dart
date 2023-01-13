import 'package:logger/logger.dart';
import 'package:wallet_connect/core/relayer/i_relayer.dart';
import 'package:wallet_connect/core/relayer/models.dart';

class PublisherTypesParams {
  final String topic;
  final String message;
  final RelayerPublishOptions opts;

  PublisherTypesParams({
    required this.topic,
    required this.message,
    required this.opts,
  });
}

abstract class IPublisher {
  String get name;
  IRelayer get relayer;
  Logger get logger;

  Future<void> publish({
    required String topic,
    required String message,
    RelayerPublishOptions? opts,
  });
}
