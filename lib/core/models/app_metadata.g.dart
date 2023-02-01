// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppMetadata _$AppMetadataFromJson(Map<String, dynamic> json) => AppMetadata(
      name: json['name'] as String,
      description: json['description'] as String,
      url: json['url'] as String,
      icons: (json['icons'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$AppMetadataToJson(AppMetadata instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'url': instance.url,
      'icons': instance.icons,
    };
