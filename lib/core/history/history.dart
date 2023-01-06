import 'package:logger/logger.dart';
import 'package:wallet_connect/core/core/constants.dart';
import 'package:wallet_connect/core/core/types.dart';
import 'package:wallet_connect/core/history/constants.dart';
import 'package:wallet_connect/core/history/types.dart';
import 'package:wallet_connect/utils/error.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/error.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';

class JsonRpcHistory extends IJsonRpcHistory {
  @override
  Map<int, JsonRpcRecord> records = {};

  final String name = HISTORY_CONTEXT;
  final String version = HISTORY_STORAGE_VERSION;

  List<JsonRpcRecord> cached = [];
  bool _initialized = false;
  final _storagePrefix = CORE_STORAGE_PREFIX;

  @override
  final ICore core;
  @override
  final Logger logger;
  @override
  final EventSubject events;

  JsonRpcHistory({
    required this.core,
    Logger? logger,
  })  : logger = logger ?? Logger(),
        events = EventSubject();

  @override
  Future<void> init() async {
    if (!_initialized) {
      logger.i('_Initialized');
      await _restore();
      cached.forEach((record) => records[record.id] = record);
      cached = [];
      _registerEventListeners();
      _initialized = true;
    }
  }

  String get storageKey => '$_storagePrefix$version//$name';

  @override
  int get size => records.length;
  @override
  List<int> get keys => records.keys.toList();
  @override
  List<JsonRpcRecord> get values => records.values.toList();

  @override
  List<RequestEvent> get pending {
    final List<RequestEvent> requests = [];
    values.forEach((record) {
      if (record.response != null) return;
      final requestEvent = RequestEvent(
        topic: record.topic,
        request: {
          'method': record.request['method'],
          'params': record.request['params'],
          'id': record.id,
        },
        chainId: record.chainId,
      );
      return requests.add(requestEvent);
    });
    return requests;
  }

  @override
  void set({
    required String topic,
    required Map<String, dynamic> request,
    String? chainId,
  }) {
    _isInitialized();
    logger.d('Setting JSON-RPC request history record');
    logger.i({
      'type': "method",
      'method': "set",
      'topic': topic,
      'request': request,
      'chainId': chainId,
    });
    if (records.containsKey(request['id'])) return;
    final record = JsonRpcRecord(
      id: request['id'],
      topic: topic,
      request: {
        'method': request['method'],
        'params': request['params'],
      },
      chainId: chainId,
    );
    records[record.id] = record;
    events.emitData(HistoryEvents.created, record);
  }

  @override
  void resolve(Map<String, dynamic> response) {
    _isInitialized();
    logger.d('Updating JSON-RPC response history record');
    logger.i({'type': "method", 'method': "update", 'response': response});
    if (!records.containsKey(response['id'])) return;
    var record = _getRecord(response['id']);
    if (record.response != null) return;
    record = record.copyWith(response: response);
    records[record.id] = record;
    events.emitData(HistoryEvents.updated, record);
  }

  @override
  JsonRpcRecord get({
    required String topic,
    required int id,
  }) {
    _isInitialized();
    logger.d('Getting record');
    logger.i({'type': "method", 'method': "get", 'topic': topic, 'id': id});
    final record = _getRecord(id);
    return record;
  }

  @override
  void delete({
    required String topic,
    int? id,
  }) {
    _isInitialized();
    logger.d('Deleting record');
    logger.i({'type': "method", 'method': "delete", 'id': id});
    values.forEach((record) {
      if (record.topic == topic) {
        if (id != null && record.id != id) return;
        records.remove(record.id);
        events.emitData(HistoryEvents.deleted, record);
      }
    });
  }

  @override
  bool exists({
    required String topic,
    required int id,
  }) {
    _isInitialized();
    if (!records.containsKey(id)) return false;
    final record = _getRecord(id);
    return record.topic == topic;
  }

  // ---------- Private ----------------------------------------------- //

  Future<void> _setJsonRpcRecords(List<JsonRpcRecord> records) async {
    final recordsJson = records.map((e) => e.toJson()).toList();
    await core.storage
        .setItem<List<Map<String, dynamic>>>(storageKey, recordsJson);
  }

  Future<List<JsonRpcRecord>> _getJsonRpcRecords() async {
    final records =
        await core.storage.getItem<List<Map<String, dynamic>>>(storageKey);
    return records?.map((e) => JsonRpcRecord.fromJson(e)).toList() ?? [];
  }

  JsonRpcRecord _getRecord(int id) {
    _isInitialized();
    final record = records[id];
    if (record == null) {
      final error = getInternalError(
        InternalErrorKey.NO_MATCHING_KEY,
        context: '${name}: ${id}',
      );
      throw WCException(error.message);
    }
    return record;
  }

  _persist() async {
    await _setJsonRpcRecords(values);
    events.emitData(HistoryEvents.sync);
  }

  _restore() async {
    try {
      final persisted = await _getJsonRpcRecords();
      if (persisted.isEmpty) return;
      if (records.isNotEmpty) {
        final error = getInternalError(
          InternalErrorKey.RESTORE_WILL_OVERRIDE,
          context: name,
        );
        logger.e(error.message);
        throw WCException(error.message);
      }
      cached = persisted;
      logger.d('Successfully Restored records for ${name}');
      logger.i({'type': "method", 'method': "_restore", records: values});
    } catch (e) {
      logger.d('Failed to Restore records for ${name}');
      logger.e(e.toString());
    }
  }

  void _registerEventListeners() {
    events.on(HistoryEvents.created, null, (event, _) {
      const eventName = HistoryEvents.created;
      final record = event.eventData as JsonRpcRecord;
      logger.i('Emitting ${eventName}');
      logger
          .d({'type': "event", 'event': eventName, 'record': record.toJson()});
      _persist();
    });
    events.on(HistoryEvents.updated, null, (event, _) {
      const eventName = HistoryEvents.updated;
      final record = event.eventData as JsonRpcRecord;
      logger.i('Emitting ${eventName}');
      logger
          .d({'type': "event", 'event': eventName, 'record': record.toJson()});
      _persist();
    });

    events.on(HistoryEvents.deleted, null, (event, _) {
      const eventName = HistoryEvents.deleted;
      final record = event.eventData as JsonRpcRecord;
      logger.i('Emitting ${eventName}');
      logger
          .d({'type': "event", 'event': eventName, 'record': record.toJson()});
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
