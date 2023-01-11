import 'package:logger/logger.dart';
import 'package:wallet_connect/core/constants.dart';
import 'package:wallet_connect/core/expirer/constants.dart';
import 'package:wallet_connect/core/expirer/types.dart';
import 'package:wallet_connect/core/i_core.dart';
import 'package:wallet_connect/utils/error.dart';
import 'package:wallet_connect/utils/misc.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/error.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';
import 'package:wallet_connect/wc_utils/misc/heartbeat/constants.dart';

class Expirer with Events implements IExpirer {
  Map<String, ExpirerTypesExpiration> expirations;

  @override
  final EventSubject events;

  @override
  final String name = EXPIRER_CONTEXT;

  final String version = EXPIRER_STORAGE_VERSION;

  List<ExpirerTypesExpiration> cached = [];

  bool _initialized = false;

  final String storagePrefix = CORE_STORAGE_PREFIX;

  @override
  final ICore core;

  @override
  final Logger logger;

  Expirer({required this.core, Logger? logger})
      : logger = logger ?? Logger(),
        events = EventSubject(),
        expirations = {};

  @override
  init() async {
    if (!_initialized) {
      logger.i('Initialized');
      await _restore();
      cached
          .forEach((expiration) => expirations[expiration.target] = expiration);
      cached = [];
      _registerEventListeners();
      _initialized = true;
    }
  }

  String get storageKey => '$storagePrefix$version//$name';

  @override
  get length => expirations.length;

  @override
  List<String> get keys => expirations.keys.toList();

  @override
  List<ExpirerTypesExpiration> get values => expirations.values.toList();

  @override
  bool has(key) {
    try {
      final target = _formatTarget(key);
      final expiration = _getExpiration(target);
      return expiration != null;
    } catch (e) {
      return false;
    }
  }

  @override
  void set(key, expiry) {
    _isInitialized();
    final target = _formatTarget(key);
    final expiration = ExpirerTypesExpiration(target: target, expiry: expiry);
    expirations[target] = expiration;
    _checkExpiry(target, expiration);
    events.emitData(
        ExpirerEvents.created,
        ExpirerTypesCreated(
          target: target,
          expiration: expiration,
        ));
  }

  @override
  ExpirerTypesExpiration get(key) {
    _isInitialized();
    final target = _formatTarget(key);
    return _getExpiration(target);
  }

  @override
  void del(key) {
    _isInitialized();
    final target = _formatTarget(key);
    final exists = has(target);
    if (exists) {
      final expiration = _getExpiration(target);
      expirations.remove(target);
      events.emitData(
          ExpirerEvents.deleted,
          ExpirerTypesDeleted(
            target: target,
            expiration: expiration,
          ));
    }
  }

  // ---------- Private ----------------------------------------------- //

  String _formatTarget(dynamic key) {
    if (key is String) {
      return formatTopicTarget(key);
    } else if (key is int) {
      return formatIdTarget(key);
    }
    final error = getInternalError(
      InternalErrorKey.UNKNOWN_TYPE,
      context: 'Target type: ${key.runtimeType}',
    );
    throw WCException(error.message);
  }

  Future<void> _setExpirations(List<ExpirerTypesExpiration> expirations) async {
    await core.storage
        .setItem<List<ExpirerTypesExpiration>>(storageKey, expirations);
  }

  Future<List<ExpirerTypesExpiration>?> _getExpirations() async {
    final expirations =
        await core.storage.getItem<List<ExpirerTypesExpiration>>(storageKey);
    return expirations;
  }

  Future<void> _persist() async {
    await _setExpirations(values);
    events.emitData(ExpirerEvents.sync);
  }

  Future<void> _restore() async {
    try {
      final persisted = await _getExpirations();
      if (persisted?.isEmpty ?? true) return;

      if (expirations.isNotEmpty) {
        final error = getInternalError(InternalErrorKey.RESTORE_WILL_OVERRIDE,
            context: name);
        logger.e(error.message);
        throw WCException(error.message);
      }
      cached = persisted!;
      logger.d('Successfully Restored expirations for $name');
      logger.i({'type': "method", 'method': "_restore", 'expirations': values});
    } catch (e) {
      logger.d('Failed to Restore expirations for $name');
      logger.e(e.toString());
    }
  }

  ExpirerTypesExpiration _getExpiration(String target) {
    final expiration = expirations[target];
    if (expiration == null) {
      final error = getInternalError(InternalErrorKey.NO_MATCHING_KEY,
          context: '$name: $target');
      logger.e(error.message);
      throw WCException(error.message);
    }
    return expiration;
  }

  bool _checkExpiry(String target, ExpirerTypesExpiration expiration) {
    final msToTimeout =
        expiration.expiry * 1000 - DateTime.now().millisecondsSinceEpoch;
    return (msToTimeout <= 0);
  }

  void _expire(String target, ExpirerTypesExpiration expiration) {
    expirations.remove(target);
    events.emitData(
        ExpirerEvents.expired,
        ExpirerTypesExpired(
          target: target,
          expiration: expiration,
        ));
  }

  void _checkExpirations() {
    expirations.entries
        .where((e) => _checkExpiry(e.key, e.value))
        .toList()
        .forEach((e) {
      _expire(e.key, e.value);
    });
  }

  void _registerEventListeners() {
    core.heartbeat.on(HeartbeatEvents.pulse, (_) => _checkExpirations());
    events.on(ExpirerEvents.created, null, (event, _) {
      const eventName = ExpirerEvents.created;
      logger.i('Emitting $eventName');
      logger.d({
        'type': "event",
        'event': eventName,
        'data': event.eventData.toString()
      });
      _persist();
    });
    events.on(ExpirerEvents.expired, null, (event, _) {
      const eventName = ExpirerEvents.expired;
      logger.i('Emitting $eventName');
      logger.d({
        'type': "event",
        'event': eventName,
        'data': event.eventData.toString()
      });
      _persist();
    });
    events.on(ExpirerEvents.deleted, null, (event, _) {
      const eventName = ExpirerEvents.deleted;
      logger.i('Emitting $eventName');
      logger.d({
        'type': "event",
        'event': eventName,
        'data': event.eventData.toString()
      });
      _persist();
    });
  }

  void _isInitialized() {
    if (!_initialized) {
      final error =
          getInternalError(InternalErrorKey.NOT_INITIALIZED, context: name);
      throw WCException(error.message);
    }
  }
}
