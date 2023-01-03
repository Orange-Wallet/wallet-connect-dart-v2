import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_connect/core/store/types.dart';
import 'package:wallet_connect/sign/sign-client/jsonrpc/types.dart';

part 'types.g.dart';

@JsonSerializable()
class PendingRequestTypesStruct {
  final String topic;
  final int id;
  final RpcSessionRequestParams params;

  PendingRequestTypesStruct(this.topic, this.id, this.params);

  factory PendingRequestTypesStruct.fromJson(Map<String, dynamic> json) =>
      _$PendingRequestTypesStructFromJson(json);

  Map<String, dynamic> toJson() => _$PendingRequestTypesStructToJson(this);
}

typedef IPendingRequest = IStore<int, PendingRequestTypesStruct>;
