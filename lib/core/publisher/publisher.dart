import 'package:logger/logger.dart';
import 'package:wallet_connect_dart_v2/core/publisher/constants.dart';
import 'package:wallet_connect_dart_v2/core/publisher/i_publisher.dart';
import 'package:wallet_connect_dart_v2/core/publisher/models.dart';
import 'package:wallet_connect_dart_v2/core/relayer/i_relayer.dart';
import 'package:wallet_connect_dart_v2/core/relayer/models.dart';
import 'package:wallet_connect_dart_v2/utils/crypto.dart';
import 'package:wallet_connect_dart_v2/utils/relay.dart';
import 'package:wallet_connect_dart_v2/wc_utils/jsonrpc/models/models.dart';
import 'package:wallet_connect_dart_v2/wc_utils/misc/heartbeat/constants.dart';
import 'package:wallet_connect_dart_v2/wc_utils/relay/models.dart';

class Publisher implements IPublisher {
  @override
  final String name = PUBLISHER_CONTEXT;

  @override
  final IRelayer relayer;

  @override
  final Logger logger;

  final Map<String, PublisherParams> _queue;

  Publisher({required this.relayer, Logger? logger})
      : logger = logger ?? Logger(),
        _queue = {} {
    _registerEventListeners();
  }

  @override
  Future<void> publish({
    required String topic,
    required String message,
    RelayerPublishOptions? opts,
  }) async {
    logger.d('Publishing Payload');
    logger.v({
      'type': "method",
      'method': "publish",
      'params': {
        'topic': topic,
        'message': message,
        'opts': opts?.toJson(),
      },
    });
    try {
      final ttl = opts?.ttl ?? PUBLISHER_DEFAULT_TTL;
      final relay = getRelayProtocolName(opts);
      final prompt = opts?.prompt ?? false;
      final tag = opts?.tag ?? 0;
      final params = PublisherParams(
        topic: topic,
        message: message,
        opts: RelayerPublishOptions(
          ttl: ttl,
          relay: relay,
          prompt: prompt,
          tag: tag,
        ),
      );
      final hash = await hashMessage(message);
      _queue[hash] = params;
      await _rpcPublish(topic, message, ttl, relay, prompt, tag);
      _onPublish(hash);
      logger.d('Successfully Published Payload');
      logger.v({
        'type': "method",
        'method': "publish",
        'params': {
          'topic': topic,
          'message': message,
          'opts': opts?.toJson(),
        },
      });
    } catch (e) {
      logger.d('Failed to Publish Payload');
      logger.e(e.toString());
      rethrow;
    }
  }

  // ---------- Private ----------------------------------------------- //

  Future<dynamic> _rpcPublish(
    String topic,
    String message,
    int ttl,
    RelayerProtocolOptions relay,
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
    logger.v({
      'type': "message",
      'direction': "outgoing",
      'request': request.toJson(),
    });
    return relayer.provider.request(request: request);
  }

  void _onPublish(String hash) {
    _queue.remove(hash);
  }

  void _checkQueue() {
    _queue.values.forEach((params) async {
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

  void _registerEventListeners() {
    relayer.core.heartbeat.on(HeartbeatEvents.pulse, (_) {
      _checkQueue();
    });
  }
}
