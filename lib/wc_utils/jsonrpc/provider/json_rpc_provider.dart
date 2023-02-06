import 'dart:async';

import 'package:wallet_connect_dart_v2/wc_utils/jsonrpc/provider/i_json_rpc_connection.dart';
import 'package:wallet_connect_dart_v2/wc_utils/jsonrpc/provider/i_json_rpc_provider.dart';
import 'package:wallet_connect_dart_v2/wc_utils/jsonrpc/models/models.dart';
import 'package:wallet_connect_dart_v2/wc_utils/jsonrpc/utils/error.dart';
import 'package:wallet_connect_dart_v2/wc_utils/jsonrpc/utils/format.dart';
import 'package:wallet_connect_dart_v2/wc_utils/jsonrpc/utils/validator.dart';
import 'package:wallet_connect_dart_v2/wc_utils/misc/events/events.dart';

class JsonRpcProvider with Events implements IJsonRpcProvider {
  @override
  final EventEmitter<String> events;

  IJsonRpcConnection? _connection;

  @override
  IJsonRpcConnection get connection => _connection!;

  bool _hasRegisteredEventListeners = false;

  JsonRpcProvider(IJsonRpcConnection connection) : events = EventEmitter() {
    _connection = setConnection(connection);
    if (this.connection.connected) {
      _registerEventListeners();
    }
  }

  @override
  Future<void> connect({dynamic connection}) => open(connection: connection);

  @override
  Future<void> disconnect() => close();

  @override
  Future<dynamic> request<Params>({
    required RequestArguments<Params> request,
    dynamic context,
  }) =>
      requestStrict(
        request: formatJsonRpcRequest<Params>(
          method: request.method,
          params: request.params,
          paramsToJson: request.paramsToJson,
        ),
        context: context,
      );

  // ---------- Protected ----------------------------------------------- //

  @override
  Future<dynamic> requestStrict<Params>({
    required JsonRpcRequest<Params> request,
    dynamic context,
  }) async {
    if (!connection.connected) {
      try {
        await open();
      } catch (e) {
        throw WCException(e.toString());
      }
    }

    try {
      final completer = Completer<dynamic>();
      events.once(request.id.toString(), (data) {
        if (isJsonRpcError(data)) {
          completer.completeError(
              JsonRpcError.fromJson(data as Map<String, dynamic>).error!);
        } else {
          completer.complete((data as Map<String, dynamic>)['result']);
        }
      });
      await connection.send(payload: request, context: context);
      return completer.future;
    } catch (e) {
      throw WCException(e.toString());
    }
  }

  @override
  IJsonRpcConnection setConnection(IJsonRpcConnection connection) {
    return connection;
  }

  @override
  void onPayload(dynamic payload) {
    events.emit("payload", payload);
    if (isJsonRpcResponse(payload)) {
      events.emit(payload['id'].toString(), payload);
    } else {
      events.emit(
          "message",
          JsonRpcProviderMessage(
            type: payload['method'],
            data: payload['params'],
          ));
    }
  }

  @override
  Future<void> open({dynamic connection}) async {
    connection ??= this.connection;
    if (this.connection == connection && this.connection.connected) return;
    if (this.connection.connected) close();
    if (connection is String) {
      await this.connection.open(url: connection);
      connection = this.connection;
    }
    _connection = setConnection(connection);
    await this.connection.open();
    _registerEventListeners();
    events.emit("connect");
  }

  @override
  Future<void> close() async {
    await connection.close();
  }

  // ---------- Private ----------------------------------------------- //

  void _registerEventListeners() {
    if (_hasRegisteredEventListeners) return;
    connection.on("payload", (data) {
      onPayload(data);
    });
    connection.on("close", (_) {
      events.emit("disconnect");
    });
    connection.on("error", (value) {
      events.emit("error", value);
    });
    _hasRegisteredEventListeners = true;
  }
}
