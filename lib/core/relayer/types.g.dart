// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RelayerProtocolOptions _$RelayerTypesProtocolOptionsFromJson(
        Map<String, dynamic> json) =>
    RelayerProtocolOptions(
      protocol: json['protocol'] as String,
      data: json['data'] as String?,
    );

Map<String, dynamic> _$RelayerTypesProtocolOptionsToJson(
    RelayerProtocolOptions instance) {
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
