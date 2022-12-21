import 'dart:convert';

import 'package:wallet_connect/wc_utils/jsonrpc/types.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/error.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/format.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../provider/types.dart';
import '../utils/url.dart';

typedef Events = void Function(String name, [dynamic data]);

class WsConnection with IEvents implements IJsonRpcConnection {
  @override
  final EventSubject events;

  WebSocketChannel? socket;

  bool registering = false;

  String url;

  WsConnection(this.url)
      : assert(isWsUrl(url),
            'Provided URL is not compatible with WebSocket connection: $url'),
        events = EventSubject();

  @override
  bool get connected => socket != null;

  @override
  bool get connecting => registering;

  @override
  Future<void> open({String? url}) async {
    url ??= this.url;
    await _register(url: url);
  }

  @override
  Future<void> close() async {
    if (socket == null) {
      throw WCException("Connection already closed");
    }
    await socket!.sink.close();
    _onClose();
  }

  @override
  Future<void> send({required JsonRpcRequest payload, dynamic context}) async {
    socket ??= await _register();
    try {
      socket!.sink.add(jsonEncode(payload.toJson()));
    } catch (e) {
      _onError(id: payload.id, e: e);
    }
  }

  // ---------- Private ----------------------------------------------- //

  Future<WebSocketChannel> _register({String? url}) async {
    url ??= this.url;
    if (!isWsUrl(url)) {
      throw WCException(
          'Provided URL is not compatible with WebSocket connection: $url');
    }

    if (registering) {
      await for (final event in events.stream) {
        if (event.name == 'register_error') {
          throw WCException(event.data);
        } else if (event.name == 'open') {
          if (socket == null) {
            throw WCException("WebSocket connection is missing or invalid");
          }
          return socket!;
        }
      }
    }
    this.url = url;
    registering = true;

    final _socket = WebSocketChannel.connect(Uri.parse(url));
    try {
      await _socket.stream.first;
      return _onOpen(_socket);
    } catch (e) {
      return _emitError(e);
    }
  }

  _onOpen(WebSocketChannel socket) {
    socket.stream.listen(
      (event) {
        _onPayload(event);
      },
      onDone: () => _onClose(),
    );
    this.socket = socket;
    registering = false;
    events.emitData("open");
  }

  _onClose() {
    socket = null;
    registering = false;
    events.emitData("close");
  }

  _onPayload(dynamic data) {
    if (data == null) return;

    final payload =
        JsonRpcResult.fromJson(data is String ? jsonDecode(data) : data);
    events.emitData("payload", payload);
  }

  _onError({required int id, required Object e}) {
    final error = _parseError(e: WCException(e.toString()));
    final payload = formatJsonRpcError(id: id, error: error.message);
    events.emitData("payload", payload);
  }

  _parseError({required WCException e, String? url}) {
    url ??= this.url;
    return parseConnectionError(e, url, "WS");
  }

  _emitError(Object? errorEvent) {
    final error = _parseError(
      e: WCException(errorEvent != null
          ? errorEvent.toString()
          : 'WebSocket connection failed for URL: $url'),
    );
    events.emitData("register_error", error);
    return error;
  }
}
