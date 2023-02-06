import 'package:json_annotation/json_annotation.dart';
import 'package:walletconnect_v2/sign/sign-client/jsonrpc/models.dart';

part 'models.g.dart';

@JsonSerializable()
class PendingRequestStruct {
  final String topic;

  final int id;

  final RequestSessionRequest params;

  PendingRequestStruct(this.topic, this.id, this.params);

  factory PendingRequestStruct.fromJson(Map<String, dynamic> json) =>
      _$PendingRequestStructFromJson(json);

  Map<String, dynamic> toJson() => _$PendingRequestStructToJson(this);
}

// 
// class PendingRequestStore {
//   
//   final String topic;
//   
//   final int id;
//   
//   final Map<String, dynamic> params;

//   PendingRequestStore(this.topic, this.id, this.params);

//   factory PendingRequestStore.fromData(PendingRequestStruct data) =>
//       PendingRequestStore(
//         data.topic,
//         data.id,
//         data.params.toJson(),
//       );

//   PendingRequestStruct toData() => PendingRequestStruct(
//         topic,
//         id,
//         RpcSessionRequestParams.fromJson(params),
//       );
// }
