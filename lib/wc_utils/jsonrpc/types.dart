import 'package:json_annotation/json_annotation.dart';

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

@JsonSerializable(genericArgumentFactories: true)
class JsonRpcRequest<T> {
  final int id;
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

@JsonSerializable()
class JsonRpcResult<T> {
  final int id;
  final String jsonrpc;
  final T? result;
  final ErrorResponse? error;

  JsonRpcResult({
    required this.id,
    required this.jsonrpc,
    this.result,
    this.error,
  });

  factory JsonRpcResult.fromJson(Map<String, dynamic> json) {
    if (json['result'] != null &&
        json['result'].containsKey('code') &&
        json['result'].containsKey('message')) {
      return JsonRpcResult(
        id: json['id']!,
        jsonrpc: json['jsonrpc']!,
        error: ErrorResponse.fromJson(json),
      );
    } else {
      return JsonRpcResult<T>(
        id: json['id']!,
        jsonrpc: json['jsonrpc']!,
        result: json['result'],
      );
    }
  }
}

@JsonSerializable()
class ErrorResponse {
  final int code;
  final String message;
  final String? data;

  const ErrorResponse({required this.code, required this.message, this.data});

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
}
