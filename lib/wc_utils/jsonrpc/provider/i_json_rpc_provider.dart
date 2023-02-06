import 'package:walletconnect_v2/wc_utils/jsonrpc/provider/i_json_rpc_connection.dart';
import 'package:walletconnect_v2/wc_utils/jsonrpc/models/models.dart';
import 'package:walletconnect_v2/wc_utils/misc/events/events.dart';

abstract class IBaseJsonRpcProvider with IEvents {
  Future<void> connect({dynamic connection});

  Future<void> disconnect();

  Future<dynamic> request<Params>({
    required RequestArguments<Params> request,
    dynamic context,
  });

  // ---------- Protected ----------------------------------------------- //

  Future<dynamic> requestStrict<Params>({
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
