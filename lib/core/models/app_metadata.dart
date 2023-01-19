import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_metadata.g.dart';

@JsonSerializable()
@HiveType(typeId: 13)
class AppMetadata {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String description;
  @HiveField(2)
  final String url;
  @HiveField(3)
  final List<String> icons;

  const AppMetadata({
    required this.name,
    required this.description,
    required this.url,
    required this.icons,
  });

  factory AppMetadata.empty() => const AppMetadata(
        name: '',
        description: '',
        url: '',
        icons: [],
      );

  factory AppMetadata.fromJson(Map<String, dynamic> json) =>
      _$AppMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$AppMetadataToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppMetadata &&
        other.name == name &&
        other.description == description &&
        other.url == url &&
        listEquals(other.icons, icons);
  }

  @override
  int get hashCode {
    return name.hashCode ^ description.hashCode ^ url.hashCode ^ icons.hashCode;
  }
}
