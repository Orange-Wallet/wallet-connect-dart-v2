import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';
import 'package:walletconnect_v2/core/i_core.dart';
import 'package:walletconnect_v2/wc_utils/misc/events/events.dart';

part 'models.g.dart';

@JsonSerializable()
class JsonRpcRecord {
  final int id;

  final String topic;

  final Map<String, dynamic> request;

  final String? chainId;

  final Map<String, dynamic>? response;

  JsonRpcRecord({
    required this.id,
    required this.topic,
    required this.request,
    this.chainId,
    this.response,
  });

  factory JsonRpcRecord.fromJson(Map<String, dynamic> json) =>
      _$JsonRpcRecordFromJson(json);

  Map<String, dynamic> toJson() => _$JsonRpcRecordToJson(this);

  JsonRpcRecord copyWith({
    int? id,
    String? topic,
    Map<String, dynamic>? request,
    String? chainId,
    Map<String, dynamic>? response,
  }) {
    return JsonRpcRecord(
      id: id ?? this.id,
      topic: topic ?? this.topic,
      request: request ?? this.request,
      chainId: chainId ?? this.chainId,
      response: response ?? this.response,
    );
  }
}

class RequestEvent {
  final String topic;
  final Map<String, dynamic> request;
  final String? chainId;

  RequestEvent({
    required this.topic,
    required this.request,
    this.chainId,
  });
}

abstract class IJsonRpcHistory with IEvents {
  Map<int, JsonRpcRecord> get records;

  int get size;

  List<int> get keys;

  List<JsonRpcRecord> get values;

  List<RequestEvent> get pending;

  ICore get core;

  Logger get logger;

  Future<void> init();

  void set({
    required String topic,
    required Map<String, dynamic> request,
    String? chainId,
  });

  JsonRpcRecord get({
    required String topic,
    required int id,
  });

  void resolve(Map<String, dynamic> response);

  void delete({required String topic, int? id});

  bool exists({
    required String topic,
    required int id,
  });
}
