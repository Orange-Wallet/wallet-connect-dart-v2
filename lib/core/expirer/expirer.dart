import 'package:logger/logger.dart';
import 'package:walletconnect_v2/core/constants.dart';
import 'package:walletconnect_v2/core/expirer/constants.dart';
import 'package:walletconnect_v2/core/expirer/i_expirer.dart';
import 'package:walletconnect_v2/core/expirer/models.dart';
import 'package:walletconnect_v2/core/i_core.dart';
import 'package:walletconnect_v2/utils/error.dart';
import 'package:walletconnect_v2/utils/list.dart';
import 'package:walletconnect_v2/utils/misc.dart';
import 'package:walletconnect_v2/wc_utils/jsonrpc/utils/error.dart';
import 'package:walletconnect_v2/wc_utils/misc/events/events.dart';
import 'package:walletconnect_v2/wc_utils/misc/heartbeat/constants.dart';

class Expirer with Events implements IExpirer {
  Map<String, ExpirerExpiration> expirations;

  @override
  final EventEmitter<String> events;

  @override
  final String name = EXPIRER_CONTEXT;

  final String version = EXPIRER_STORAGE_VERSION;

  final String storagePrefix = CORE_STORAGE_PREFIX;

  @override
  final ICore core;

  @override
  final Logger logger;

  List<ExpirerExpiration> _cached;

  bool _initialized;

  Expirer({required this.core, Logger? logger})
      : logger = logger ?? Logger(),
        events = EventEmitter(),
        expirations = {},
        _cached = [],
        _initialized = false;

  @override
  Future<void> init() async {
    if (!_initialized) {
      logger.i('Initialized');
      await _restore();
      _cached
          .forEach((expiration) => expirations[expiration.target] = expiration);
      _cached = [];
      _registerEventListeners();
      _initialized = true;
    }
  }

  String get storageKey => '$storagePrefix$version//$name';

  @override
  int get length => expirations.length;

  @override
  List<String> get keys => expirations.keys.toList();

  @override
  List<ExpirerExpiration> get values => expirations.values.toList();

  @override
  bool has(dynamic key) {
    try {
      final target = _formatTarget(key);
      final expiration = _getExpiration(target);
      return expiration != null;
    } catch (e) {
      return false;
    }
  }

  @override
  void set(dynamic key, int expiry) {
    _isInitialized();
    final target = _formatTarget(key);
    final expiration = ExpirerExpiration(target: target, expiry: expiry);
    expirations[target] = expiration;
    _checkExpiry(target, expiration);
    events.emit(
        ExpirerEvents.created,
        ExpirerEvent(
          target: target,
          expiration: expiration,
        ));
  }

  @override
  ExpirerExpiration get(dynamic key) {
    _isInitialized();
    final target = _formatTarget(key);
    return _getExpiration(target);
  }

  @override
  void del(dynamic key) {
    _isInitialized();
    final target = _formatTarget(key);
    final exists = has(target);
    if (exists) {
      final expiration = _getExpiration(target);
      expirations.remove(target);
      events.emit(
          ExpirerEvents.deleted,
          ExpirerEvent(
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

  Future<void> _setExpirations(List<ExpirerExpiration> expirations) async {
    await core.storage.setItem(
      storageKey,
      listToJson<ExpirerExpiration>(expirations, (v) => v.toJson()),
    );
  }

  Future<List<ExpirerExpiration>?> _getExpirations() async {
    final expirations = await core.storage.getItem(storageKey);
    return listFromJson<ExpirerExpiration>(
            expirations, (v) => ExpirerExpiration.fromJson(v)) ??
        [];
  }

  Future<void> _persist() async {
    await _setExpirations(values);
    events.emit(ExpirerEvents.sync);
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
      _cached = persisted!;
      logger.d('Successfully Restored expirations for $name');
      logger.v({
        'type': "method",
        'method': "_restore",
        'expirations': values.map((e) => e.toJson()).toList(),
      });
    } catch (e) {
      logger.d('Failed to Restore expirations for $name');
      logger.e(e.toString());
    }
  }

  ExpirerExpiration _getExpiration(String target) {
    final expiration = expirations[target];
    if (expiration == null) {
      final error = getInternalError(InternalErrorKey.NO_MATCHING_KEY,
          context: '$name: $target');
      logger.e(error.message);
      throw WCException(error.message);
    }
    return expiration;
  }

  bool _checkExpiry(String target, ExpirerExpiration expiration) {
    final msToTimeout =
        expiration.expiry * 1000 - DateTime.now().millisecondsSinceEpoch;
    return (msToTimeout <= 0);
  }

  void _expire(String target, ExpirerExpiration expiration) {
    expirations.remove(target);
    events.emit(
        ExpirerEvents.expired,
        ExpirerEvent(
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
    events.on(ExpirerEvents.created, (data) {
      const eventName = ExpirerEvents.created;
      logger.i('Emitting $eventName');
      logger.v({
        'type': "event",
        'event': eventName,
        'data': (data as ExpirerEvent?)?.toJson(),
      });
      _persist();
    });
    events.on(ExpirerEvents.expired, (data) {
      const eventName = ExpirerEvents.expired;
      logger.i('Emitting $eventName');
      logger.v({
        'type': "event",
        'event': eventName,
        'data': (data as ExpirerEvent?)?.toJson(),
      });
      _persist();
    });
    events.on(ExpirerEvents.deleted, (data) {
      const eventName = ExpirerEvents.deleted;
      logger.i('Emitting $eventName');
      logger.v({
        'type': "event",
        'event': eventName,
        'data': (data as ExpirerEvent?)?.toJson(),
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
