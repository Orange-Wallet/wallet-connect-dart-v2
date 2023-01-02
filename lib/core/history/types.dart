import 'package:logger/logger.dart';
import 'package:wallet_connect/core/core/types.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/types.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';

class JsonRpcRecord {
  final int id;
  final String topic;
  final RequestArguments request;
  final String? chainId;
  final JsonRpcResponse? response;

  JsonRpcRecord({
    required this.id,
    required this.topic,
    required this.request,
    this.chainId,
    this.response,
  });
}

class RequestEvent {
  final String topic;
  final JsonRpcRequest request;
  final String? chainId;

  RequestEvent({
    required this.topic,
    required this.request,
    this.chainId,
  });
}

abstract class IJsonRpcHistory with IEvents {
  Map<int, JsonRpcRecord> get records;

  String get context;

  int get size;

  List<int> get keys;

  List<JsonRpcRecord> get values;

  List<RequestEvent> get pending;

  ICore get core;

  Logger get logger;

  Future<void> init();

  void set({
    required String topic,
    required JsonRpcRequest request,
    String? chainId,
  });

  Future<JsonRpcRecord> get({
    required String topic,
    required int id,
  });

  Future<void> resolve(JsonRpcResponse response);

  void delete({required String topic, int? id});

  Future<bool> exists({
    required String topic,
    required int id,
  });
}
