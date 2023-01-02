import 'package:wallet_connect/core/store/types.dart';
import 'package:wallet_connect/sign/sign-client/jsonrpc/types.dart';

class PendingRequestTypesStruct {
  final String topic;
  final int id;
  final RpcSessionRequestParams params;

  PendingRequestTypesStruct(this.topic, this.id, this.params);
}

typedef IPendingRequest = IStore<int, PendingRequestTypesStruct>;
