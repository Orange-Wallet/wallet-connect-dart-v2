import 'dart:async';
import 'dart:convert';

import 'package:wallet_connect/wc_utils/jsonrpc/provider/types.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/types.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/error.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/format.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/url.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsConnection with Events implements IJsonRpcConnection {
  @override
  final EventEmitter<String> events;

  WebSocketChannel? socket;

  bool registering = false;

  String url;

  WsConnection(this.url)
      : assert(isWsUrl(url),
            'Provided URL is not compatible with WebSocket connection: $url'),
        events = EventEmitter();

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
  Future<void> send({required JsonRpcPayload payload, dynamic context}) async {
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
      final completer = Completer<WebSocketChannel>();
      events.once('register_error', (event) {
        completer.completeError(WCException(event!.toString()));
      });
      events.once('open', (event) {
        if (socket == null) {
          completer.completeError(
              WCException("WebSocket connection is missing or invalid"));
        }
        completer.complete(socket!);
      });
      return completer.future;
    }
    this.url = url;
    registering = true;

    final webSocket = WebSocketChannel.connect(Uri.parse(url));
    webSocket.stream.listen(
      (event) {
        _onPayload(event);
      },
      onError: (e) {
        throw _emitError(e);
      },
      onDone: () {
        _onClose();
      },
    );
    return _onOpen(webSocket);
  }

  WebSocketChannel _onOpen(WebSocketChannel socket) {
    this.socket = socket;
    registering = false;
    events.emit("open");
    return socket;
  }

  _onClose() {
    socket = null;
    registering = false;
    events.emit("close");
  }

  _onPayload(dynamic data) {
    if (data == null) return;
    final payload = data is String ? jsonDecode(data) : data;
    events.emit("payload", payload);
  }

  _onError({required int id, required Object e}) {
    final error = _parseError(e: WCException(e.toString()));
    final payload = formatJsonRpcError(id: id, error: error.message);
    events.emit("payload", payload.toJson());
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
    events.emit("register_error", error);
    return error;
  }
}
