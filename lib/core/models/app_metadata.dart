import 'package:flutter/foundation.dart';

import 'package:json_annotation/json_annotation.dart';

part 'app_metadata.g.dart';

@JsonSerializable()
class AppMetadata {
  final String name;

  final String description;

  final String url;

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
