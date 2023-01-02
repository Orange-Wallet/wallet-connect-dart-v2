import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_connect/utils/validator.dart';

part 'types.g.dart';

class JsonRpcProviderMessage<T> {
  final String type;
  final T data;

  JsonRpcProviderMessage({required this.type, required this.data});
}

@JsonSerializable(genericArgumentFactories: true)
class RequestArguments<T> {
  final String method;
  final T? params;
  @JsonKey(ignore: true)
  final Object? Function(T value)? paramsToJson;

  RequestArguments({
    required this.method,
    this.params,
    this.paramsToJson,
  });

  factory RequestArguments.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$RequestArgumentsFromJson(json, fromJsonT);

  Map<String, dynamic> toJson() =>
      _$RequestArgumentsToJson(this, paramsToJson ?? (_) => null);
}

abstract class JsonRpcPayload<T> {
  int get id;
  String get jsonrpc;

  Map<String, dynamic> toJson();
}

@JsonSerializable(genericArgumentFactories: true)
class JsonRpcRequest<T> extends RequestArguments<T>
    implements JsonRpcPayload<T> {
  @override
  final int id;
  @override
  final String jsonrpc;

  JsonRpcRequest({
    required this.id,
    required this.jsonrpc,
    required super.method,
    super.params,
    super.paramsToJson,
  });

  factory JsonRpcRequest.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$JsonRpcRequestFromJson(json, fromJsonT);

  @override
  Map<String, dynamic> toJson() =>
      _$JsonRpcRequestToJson(this, super.paramsToJson ?? (_) => null);
}

abstract class JsonRpcResponse<T> implements JsonRpcPayload<T> {}

@JsonSerializable(genericArgumentFactories: true)
class JsonRpcResult<T extends Object?> implements JsonRpcResponse<T> {
  @override
  final int id;
  @override
  final String jsonrpc;
  final T? result;
  @JsonKey(ignore: true)
  final Object? Function(T value)? resultToJson;

  const JsonRpcResult({
    required this.id,
    required this.jsonrpc,
    this.result,
    this.resultToJson,
  });

  factory JsonRpcResult.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$JsonRpcResultFromJson(json, fromJsonT);

  @override
  Map<String, dynamic> toJson() =>
      _$JsonRpcResultToJson(this, resultToJson ?? (_) => null);
}

@JsonSerializable()
class JsonRpcError implements JsonRpcResponse<ErrorResponse> {
  @override
  final int id;
  @override
  final String jsonrpc;
  final ErrorResponse? error;

  JsonRpcError({
    required this.id,
    required this.jsonrpc,
    this.error,
  });

  factory JsonRpcError.fromJson(Map<String, dynamic> json) =>
      _$JsonRpcErrorFromJson(json);

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jsonrpc': jsonrpc,
      'error': error?.toJson(),
    };
  }
}

@JsonSerializable()
class ErrorResponse extends ErrorObject {
  final String? data;

  const ErrorResponse({required super.code, required super.message, this.data});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);

  ErrorResponse copyWith({
    int? code,
    String? message,
    String? data,
  }) {
    return ErrorResponse(
      code: code ?? this.code,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }

  @override
  String toString() =>
      'ErrorResponse(code: $code, message: $message, data: $data)';
}
