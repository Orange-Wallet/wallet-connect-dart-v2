import 'package:wallet_connect/wc_utils/jsonrpc/types.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';

abstract class IJsonRpcConnection with IEvents {
  bool get connected;
  bool get connecting;

  Future<void> open({String? url});
  Future<void> close();
  Future<void> send({required JsonRpcPayload payload, dynamic context});
}

abstract class IBaseJsonRpcProvider with IEvents {
  Future<void> connect({dynamic connection});

  Future<void> disconnect();

  Future<Result?> request<Result, Params>({
    required RequestArguments<Params> request,
    dynamic context,
  });

  // ---------- Protected ----------------------------------------------- //

  Future<Result?> requestStrict<Result, Params>({
    required JsonRpcRequest<Params> request,
    dynamic context,
  });
}

abstract class IJsonRpcProvider extends IBaseJsonRpcProvider {
  IJsonRpcConnection get connection;

  // ---------- Protected ----------------------------------------------- //

  IJsonRpcConnection setConnection(IJsonRpcConnection connection);

  void onPayload(JsonRpcResult payload);

  Future<void> open({dynamic connection});

  Future<void> close();
}
