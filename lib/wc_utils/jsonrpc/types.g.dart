// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestArguments<T> _$RequestArgumentsFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    RequestArguments<T>(
      method: json['method'] as String,
      params: _$nullableGenericFromJson(json['params'], fromJsonT),
    );

Map<String, dynamic> _$RequestArgumentsToJson<T>(
  RequestArguments<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'method': instance.method,
      'params': _$nullableGenericToJson(instance.params, toJsonT),
    };

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

JsonRpcRequest<T> _$JsonRpcRequestFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    JsonRpcRequest<T>(
      id: json['id'] as int,
      jsonrpc: json['jsonrpc'] as String,
      method: json['method'] as String,
      params: _$nullableGenericFromJson(json['params'], fromJsonT),
    );

Map<String, dynamic> _$JsonRpcRequestToJson<T>(
  JsonRpcRequest<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'method': instance.method,
      'params': _$nullableGenericToJson(instance.params, toJsonT),
      'id': instance.id,
      'jsonrpc': instance.jsonrpc,
    };

JsonRpcResult<T> _$JsonRpcResultFromJson<T extends Object?>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    JsonRpcResult<T>(
      id: json['id'] as int,
      jsonrpc: json['jsonrpc'] as String,
      result: _$nullableGenericFromJson(json['result'], fromJsonT),
    );

Map<String, dynamic> _$JsonRpcResultToJson<T extends Object?>(
  JsonRpcResult<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'id': instance.id,
      'jsonrpc': instance.jsonrpc,
      'result': _$nullableGenericToJson(instance.result, toJsonT),
    };

JsonRpcError _$JsonRpcErrorFromJson(Map<String, dynamic> json) => JsonRpcError(
      id: json['id'] as int,
      jsonrpc: json['jsonrpc'] as String,
      error: json['error'] == null
          ? null
          : ErrorResponse.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$JsonRpcErrorToJson(JsonRpcError instance) =>
    <String, dynamic>{
      'id': instance.id,
      'jsonrpc': instance.jsonrpc,
      'error': instance.error,
    };

ErrorResponse _$ErrorResponseFromJson(Map<String, dynamic> json) =>
    ErrorResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'] as String?,
    );

Map<String, dynamic> _$ErrorResponseToJson(ErrorResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'code': instance.code,
      'data': instance.data,
    };
