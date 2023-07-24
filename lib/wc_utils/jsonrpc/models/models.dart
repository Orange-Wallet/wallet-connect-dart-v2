import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_connect_dart_v2/utils/validator.dart';

class JsonRpcProviderMessage<T> {
  final String type;
  final T data;

  JsonRpcProviderMessage({required this.type, required this.data});
}

class RequestArguments<T> {
  final String method;
  final T? params;
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
      RequestArguments<T>(
        method: json['method'] as String,
        params: _$nullableGenericFromJson(json['params'], fromJsonT),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'method': method,
        'params': _$nullableGenericToJson(
          params,
          paramsToJson ?? (v) => v,
        ),
      };
}

abstract class JsonRpcPayload<T> {
  dynamic get id;
  String get jsonrpc;

  Map<String, dynamic> toJson();
}

class JsonRpcRequest<T> extends RequestArguments<T>
    implements JsonRpcPayload<T> {
  @override
  final dynamic id;
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
      JsonRpcRequest<T>(
        id: json['id'] as int,
        jsonrpc: json['jsonrpc'] as String,
        method: json['method'] as String,
        params: _$nullableGenericFromJson(json['params'], fromJsonT),
      );

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'jsonrpc': jsonrpc,
        'method': method,
        'params':
            _$nullableGenericToJson(params, super.paramsToJson ?? (v) => v),
      };
}

abstract class JsonRpcResponse<T> implements JsonRpcPayload<T> {}

class JsonRpcResult<T extends Object?> implements JsonRpcResponse<T> {
  @override
  final dynamic id;
  @override
  final String jsonrpc;
  final T? result;
  @JsonKey(ignore: true)
  final Object? Function(T value)? resultToJson;

  const JsonRpcResult({
    required this.id,
    this.jsonrpc = '2.0',
    this.result,
    this.resultToJson,
  });

  factory JsonRpcResult.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      JsonRpcResult<T>(
        id: json['id'] as int,
        jsonrpc: json['jsonrpc'] as String,
        result: _$nullableGenericFromJson(json['result'], fromJsonT),
      );

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'jsonrpc': jsonrpc,
        'result': _$nullableGenericToJson(
          result,
          resultToJson ?? (v) => v,
        ),
      };
}

class JsonRpcError implements JsonRpcResponse<ErrorResponse> {
  @override
  final dynamic id;
  @override
  final String jsonrpc;
  final ErrorResponse? error;

  JsonRpcError({
    required this.id,
    this.jsonrpc = '2.0',
    this.error,
  });

  factory JsonRpcError.fromJson(Map<String, dynamic> json) => JsonRpcError(
        id: json['id'] as int,
        jsonrpc: json['jsonrpc'] as String,
        error: json['error'] == null
            ? null
            : ErrorResponse.fromJson(json['error'] as Map<String, dynamic>),
      );

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'jsonrpc': jsonrpc,
        'error': error?.toJson(),
      };
}

class ErrorResponse extends ErrorObject {
  final String? data;

  const ErrorResponse({required super.code, required super.message, this.data});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) => ErrorResponse(
        code: json['code'] as int,
        message: json['message'] as String,
        data: json['data'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'code': code,
        'message': message,
        'data': data,
      };

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

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);
