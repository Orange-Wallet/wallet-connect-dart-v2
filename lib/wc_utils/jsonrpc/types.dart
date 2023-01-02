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

  RequestArguments({required this.method, this.params});

  factory RequestArguments.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$RequestArgumentsFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(
    Object? Function(T value) toJsonT,
  ) =>
      _$RequestArgumentsToJson(this, toJsonT);
}

// @JsonSerializable(genericArgumentFactories: true)
// class JsonRpcRequest<T> extends RequestArguments<T> {
//   final int id;
//   final String jsonrpc;

//   JsonRpcRequest({
//     required this.id,
//     required this.jsonrpc,
//     required String method,
//     T? params,
//   }) : super(method: method, params: params);

//   factory JsonRpcRequest.fromJson(
//     Map<String, dynamic> json,
//     T Function(Object? json) fromJsonT,
//   ) =>
//       _$JsonRpcRequestFromJson(json, fromJsonT);

//   Map<String, dynamic> toJson(
//     Object? Function(T value) toJsonT,
//   ) =>
//       _$JsonRpcRequestToJson(this, toJsonT);

// }

abstract class JsonRpcPayload {
  int get id;
  String get jsonrpc;

  // Map<String, dynamic> toJson();
}

@JsonSerializable(genericArgumentFactories: true)
class JsonRpcRequest<T> implements JsonRpcPayload {
  @override
  final int id;
  @override
  final String jsonrpc;
  final String method;
  final T? params;

  JsonRpcRequest({
    required this.id,
    required this.jsonrpc,
    required this.method,
    this.params,
  });

  factory JsonRpcRequest.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$JsonRpcRequestFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(
    Object? Function(T value) toJsonT,
  ) =>
      _$JsonRpcRequestToJson(this, toJsonT);
}

abstract class JsonRpcResponse implements JsonRpcPayload {}

@JsonSerializable(genericArgumentFactories: true)
class JsonRpcResult<T> implements JsonRpcResponse {
  @override
  final int id;
  @override
  final String jsonrpc;
  final T? result;

  JsonRpcResult({
    required this.id,
    required this.jsonrpc,
    this.result,
  });

  // factory JsonRpcResult.fromJson(Map<String, dynamic> json) {
  // if (json['result'] != null &&
  //     json['result'].containsKey('code') &&
  //     json['result'].containsKey('message')) {
  //   return JsonRpcResult(
  //     id: json['id']!,
  //     jsonrpc: json['jsonrpc']!,
  //     error: ErrorResponse.fromJson(json),
  //   );
  // } else {
  //   return JsonRpcResult<T>(
  //     id: json['id']!,
  //     jsonrpc: json['jsonrpc']!,
  //     result: json['result'],
  //   );
  // }
  // }

  factory JsonRpcResult.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$JsonRpcResultFromJson(json, fromJsonT);

  // Map<String, dynamic> toJson(
  //   Object? Function(T value) toJsonT,
  // ) =>
  //     _$JsonRpcResultToJson(this, toJsonT);

  // @override
  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'jsonrpc': jsonrpc,
  //     // TODO: result converter
  //     'result': null,
  //   };
  // }
}

@JsonSerializable()
class JsonRpcError implements JsonRpcResponse {
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
