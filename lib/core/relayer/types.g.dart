// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RelayerTypesProtocolOptions _$RelayerTypesProtocolOptionsFromJson(
        Map<String, dynamic> json) =>
    RelayerTypesProtocolOptions(
      protocol: json['protocol'] as String,
      data: json['data'] as String?,
    );

Map<String, dynamic> _$RelayerTypesProtocolOptionsToJson(
    RelayerTypesProtocolOptions instance) {
  final val = <String, dynamic>{
    'protocol': instance.protocol,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('data', instance.data);
  return val;
}
