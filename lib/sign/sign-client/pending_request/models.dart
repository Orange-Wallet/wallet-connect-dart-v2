import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_connect/sign/sign-client/jsonrpc/models.dart';

part 'models.g.dart';

@JsonSerializable()
class PendingRequestStruct {
  final String topic;
  final int id;
  final RpcSessionRequestParams params;

  PendingRequestStruct(this.topic, this.id, this.params);

  factory PendingRequestStruct.fromJson(Map<String, dynamic> json) =>
      _$PendingRequestStructFromJson(json);

  Map<String, dynamic> toJson() => _$PendingRequestStructToJson(this);
}
