import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_connect/sign/sign-client/jsonrpc/models.dart';

part 'models.g.dart';

@JsonSerializable()
@HiveType(typeId: 4)
class PendingRequestStruct {
  @HiveField(0)
  final String topic;
  @HiveField(1)
  final int id;
  @HiveField(2)
  final RpcSessionRequestParams params;

  PendingRequestStruct(this.topic, this.id, this.params);

  factory PendingRequestStruct.fromJson(Map<String, dynamic> json) =>
      _$PendingRequestStructFromJson(json);

  Map<String, dynamic> toJson() => _$PendingRequestStructToJson(this);
}

// @HiveType(typeId: 4)
// class PendingRequestStore extends HiveObject {
//   @HiveField(0)
//   final String topic;
//   @HiveField(1)
//   final int id;
//   @HiveField(2)
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
