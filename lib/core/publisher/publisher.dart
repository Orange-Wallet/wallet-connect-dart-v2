import 'package:logger/logger.dart';
import 'package:wallet_connect/core/publisher/constants.dart';
import 'package:wallet_connect/core/publisher/types.dart';
import 'package:wallet_connect/core/relayer/types.dart';
import 'package:wallet_connect/utils/crypto.dart';
import 'package:wallet_connect/utils/relay.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/types.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';
import 'package:wallet_connect/wc_utils/misc/heartbeat/constants.dart';
import 'package:wallet_connect/wc_utils/relay/types.dart';

class Publisher implements IPublisher {
  @override
  final EventSubject events;
  @override
  final String name = PUBLISHER_CONTEXT;
  @override
  final IRelayer relayer;
  @override
  final Logger logger;

  Publisher({required this.relayer, Logger? logger})
      : events = EventSubject(),
        logger = logger ?? Logger() {
    _registerEventListeners();
  }

  Map<String, PublisherTypesParams> queue = {};

  @override
  Future<void> publish({
    required String topic,
    required String message,
    RelayerTypesPublishOptions? opts,
  }) async {
    logger.d('Publishing Payload');
    logger.i({
      'type': "method",
      'method': "publish",
      'params': {topic, message, opts}
    });
    try {
      final ttl = opts?.ttl ?? PUBLISHER_DEFAULT_TTL;
      final relay = getRelayProtocolName(opts);
      final prompt = opts?.prompt ?? false;
      final tag = opts?.tag ?? 0;
      final params = PublisherTypesParams(
        topic: topic,
        message: message,
        opts: RelayerTypesPublishOptions(
          ttl: ttl,
          relay: relay,
          prompt: prompt,
          tag: tag,
        ),
      );
      final hash = await hashMessage(message);
      queue[hash] = params;
      await _rpcPublish(topic, message, ttl, relay, prompt, tag);
      _onPublish(hash);
      logger.d('Successfully Published Payload');
      logger.i({
        'type': "method",
        'method': "publish",
        'params': {topic, message, opts}
      });
    } catch (e) {
      logger.d('Failed to Publish Payload');
      logger.e(e.toString());
      rethrow;
    }
  }

  // ---------- Private ----------------------------------------------- //

  _rpcPublish(
    String topic,
    String message,
    int ttl,
    RelayerTypesProtocolOptions relay,
    bool? prompt,
    int? tag,
  ) {
    final api = getRelayProtocolApi(relay.protocol);
    final request = RequestArguments<RelayJsonRpcPublishParams>(
      method: api.publish,
      params: RelayJsonRpcPublishParams(
        topic: topic,
        message: message,
        ttl: ttl,
        prompt: prompt,
        tag: tag,
      ),
      paramsToJson: (value) => value.toJson(),
    );
    logger.d('Outgoing Relay Payload');
    logger.i({'type': "message", 'direction': "outgoing", 'request': request});
    return relayer.provider.request(request: request);
  }

  _onPublish(String hash) {
    queue.remove(hash);
  }

  _checkQueue() {
    queue.values.forEach((params) async {
      final hash = await hashMessage(params.message);
      await _rpcPublish(
        params.topic,
        params.message,
        params.opts.ttl!,
        params.opts.relay!,
        params.opts.prompt,
        params.opts.tag,
      );
      _onPublish(hash);
    });
  }

  _registerEventListeners() {
    relayer.core.heartbeat.on(HeartbeatEvents.pulse, (_) {
      _checkQueue();
    });
  }

  @override
  void on(String event, void Function(dynamic data) callback) {}
}
