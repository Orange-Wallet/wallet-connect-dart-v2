import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';

import 'package:wallet_connect/core/crypto/types.dart';
import 'package:wallet_connect/core/expirer/types.dart';
import 'package:wallet_connect/core/history/types.dart';
import 'package:wallet_connect/core/pairing/types.dart';
import 'package:wallet_connect/core/relayer/types.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';
import 'package:wallet_connect/wc_utils/misc/heartbeat/types.dart';
import 'package:wallet_connect/wc_utils/misc/keyvaluestorage/types.dart';

part 'types.g.dart';

@JsonSerializable()
class Metadata {
  final String name;
  final String description;
  final String url;
  final List<String> icons;

  const Metadata({
    required this.name,
    required this.description,
    required this.url,
    required this.icons,
  });

  factory Metadata.empty() => const Metadata(
        name: '',
        description: '',
        url: '',
        icons: [],
      );

  factory Metadata.fromJson(Map<String, dynamic> json) =>
      _$MetadataFromJson(json);

  Map<String, dynamic> toJson() => _$MetadataToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Metadata &&
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

abstract class ICore with IEvents {
  String get protocol;
  int get version;

  Logger get logger;
  IHeartBeat get heartbeat;
  ICrypto get crypto;
  IRelayer get relayer;
  IKeyValueStorage get storage;
  IJsonRpcHistory get history;
  IExpirer get expirer;
  IPairing get pairing;

  String get name;
  String? get projectId;
  String? get relayUrl;

  Future<void> start();
}
