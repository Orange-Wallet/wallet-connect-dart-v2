import 'package:wallet_connect/wc_utils/jsonrpc/types.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/error.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/format.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';

import 'types.dart';

class JsonRpcProvider with IEvents implements IJsonRpcProvider {
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
  Future<Result?> request<Result, Params>({
    required RequestArguments<Params> request,
    dynamic context,
  }) =>
      requestStrict(
        request: formatJsonRpcRequest<Params>(
          method: request.method,
          params: request.params,
        ),
        context: context,
      );

  // ---------- Protected ----------------------------------------------- //

  @override
  Future<Result?> requestStrict<Result, Params>({
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
      connection.send(payload: request, context: context);

      await for (final event in events) {
        if (event.name == request.id.toString()) {
          if (event.data is JsonRpcResult) {
            if (event.data.error != null) {
              return event.data.error;
            } else {
              return event.data.result;
            }
          }
        }
      }
      return null;
    } catch (e) {
      throw WCException(e.toString());
    }
  }

  @override
  IJsonRpcConnection setConnection(IJsonRpcConnection connection) {
    return connection;
  }

  @override
  void onPayload(JsonRpcResult payload) {
    events.emitData("payload", payload);
    // if (isJsonRpcResponse(payload)) {
    events.emitData(payload.id.toString(), payload);
    // } else {
    // events.emitData("message",JsonRpcProviderMessage(
    //   type: payload.method,
    //   data: payload.params,
    //  ));
    // }
  }

  @override
  Future<void> open({dynamic connection}) async {
    if (this.connection == connection && this.connection.connected) return;
    if (this.connection.connected) close();
    if (connection == "string") {
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
      onPayload(data.eventData as JsonRpcResult);
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
