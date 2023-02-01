import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

@JsonSerializable()
class ExpirerExpiration {
  final String target;

  final int expiry;

  ExpirerExpiration({
    required this.target,
    required this.expiry,
  });

  factory ExpirerExpiration.fromJson(Map<String, dynamic> json) =>
      _$ExpirerExpirationFromJson(json);

  Map<String, dynamic> toJson() => _$ExpirerExpirationToJson(this);
}

@JsonSerializable()
class ExpirerEvent {
  final String target;
  final ExpirerExpiration expiration;

  ExpirerEvent({
    required this.target,
    required this.expiration,
  });

  factory ExpirerEvent.fromJson(Map<String, dynamic> json) =>
      _$ExpirerEventFromJson(json);

  Map<String, dynamic> toJson() => _$ExpirerEventToJson(this);
}
