import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:wallet_connect_v2/core/constants.dart';
import 'package:wallet_connect_v2/core/i_core.dart';
import 'package:wallet_connect_v2/core/messages/constants.dart';
import 'package:wallet_connect_v2/core/messages/i_message_tracker.dart';
import 'package:wallet_connect_v2/utils/crypto.dart';
import 'package:wallet_connect_v2/utils/error.dart';
import 'package:wallet_connect_v2/wc_utils/jsonrpc/utils/error.dart';

class MessageTracker implements IMessageTracker {
  @override
  Map<String, MessageRecord> messages;

  @override
  final String name = MESSAGES_CONTEXT;

  final String version = MESSAGES_STORAGE_VERSION;

  final storagePrefix = CORE_STORAGE_PREFIX;

  @override
  final Logger logger;

  @override
  final ICore core;

  bool _initialized = false;

  MessageTracker({
    required this.core,
    Logger? logger,
  })  : logger = logger ?? Logger(),
        messages = {};

  @override
  Future<void> init() async {
    if (!_initialized) {
      logger.i('Initialized');
      try {
        final msgs = await _getRelayerMessages();
        if (msgs != null) {
          messages = msgs;
        }

        logger.d('Successfully Restored records for $name');
        logger.v({
          'type': "method",
          'method': "restore",
          'size': messages.length,
        });
      } catch (e) {
        logger.d('Failed to Restore records for $name');
        logger.e(e.toString());
      } finally {
        _initialized = true;
      }
    }
  }

  String get storageKey => '$storagePrefix$version//$name';

  @override
  Future<String> set(String topic, String message) async {
    _isInitialized();
    final hash = await hashMessage(message);
    final msgs = messages[topic] ?? {};
    if (messages[hash] != null) {
      return hash;
    }
    msgs[hash] = message;
    messages[topic] = msgs;
    await _persist();
    return hash;
  }

  @override
  Map<String, String> get(topic) {
    _isInitialized();
    return messages[topic] ?? {};
  }

  @override
  Future<bool> has(topic, message) async {
    _isInitialized();
    final messages = get(topic);
    final hash = await hashMessage(message);
    return messages[hash] != null;
  }

  @override
  Future<void> del(topic) async {
    _isInitialized();
    messages.remove(topic);
    await _persist();
  }

  // ---------- Private ----------------------------------------------- //

  Future<void> _setRelayerMessages(Map<String, MessageRecord> messages) =>
      core.storage.setItem(storageKey, jsonEncode(messages));

  Future<Map<String, MessageRecord>?> _getRelayerMessages() async {
    final messages = await core.storage.getItem(storageKey);
    return messages == null
        ? null
        : Map<String, MessageRecord>.from(Map<String, dynamic>.from(
            jsonDecode(messages)
                .map((k, v) => MapEntry(k, Map<String, String>.from(v)))));
  }

  Future<void> _persist() async {
    await _setRelayerMessages(messages);
  }

  void _isInitialized() {
    if (!_initialized) {
      final error =
          getInternalError(InternalErrorKey.NOT_INITIALIZED, context: name);
      throw WCException(error.message);
    }
  }
}
