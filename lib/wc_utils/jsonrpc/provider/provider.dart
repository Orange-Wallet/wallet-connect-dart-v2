import 'dart:async';

import 'package:wallet_connect/wc_utils/jsonrpc/types.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/error.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/format.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/validator.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';

import 'types.dart';

class JsonRpcProvider with Events implements IJsonRpcProvider {
  @override
  final EventSubject events;

  IJsonRpcConnection? _connection;

  @override
  IJsonRpcConnection get connection => _connection!;

  bool _hasRegisteredEventListeners = false;

  JsonRpcProvider(IJsonRpcConnection connection) : events = EventSubject() {
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
      events.once(request.id.toString(), null, (event, _) {
        if (isJsonRpcError(event.eventData)) {
          completer.completeError(
              JsonRpcError.fromJson(event.eventData as Map<String, dynamic>)
                  .error!);
        } else {
          completer
              .complete((event.eventData as Map<String, dynamic>)['result']);
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
    events.emitData("payload", payload);
    // if (isJsonRpcResponse(payload)) {
    events.emitData(payload['id'].toString(), payload);
    // } else {
    // events.emitData("message",JsonRpcProviderMessage(
    //   type: payload.method,
    //   data: payload.params,
    //  ));
    // }
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
    events.emitData("connect");
  }

  @override
  close() async {
    await connection.close();
  }

  // ---------- Private ----------------------------------------------- //

  _registerEventListeners() {
    if (_hasRegisteredEventListeners) return;
    connection.on("payload", (data) {
      onPayload(data.eventData);
    });
    connection.on("close", (_) {
      events.emitData("disconnect");
    });
    connection.on("error", (value) {
      events.emitData("error", value);
    });
    _hasRegisteredEventListeners = true;
  }
}
