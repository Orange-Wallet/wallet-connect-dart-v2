import 'package:logger/logger.dart';
import 'package:wallet_connect_dart_v2/core/i_core.dart';
import 'package:wallet_connect_dart_v2/core/models/app_metadata.dart';
import 'package:wallet_connect_dart_v2/core/pairing/models.dart';
import 'package:wallet_connect_dart_v2/core/store/i_store.dart';

abstract class IPairing {
  String get name;

  IStore<String, PairingStruct> get pairings;

  ICore get core;

  Logger get logger;

  Future<void> init();

  Future<PairingStruct> pair({
    required String uri,
    bool activatePairing = false,
  });

  // for proposer to create inactive pairing
  Future<PairingCreated> create();

  // for either to activate a previously created pairing
  Future<void> activate({required String topic});

  // for both to subscribe on methods requests
  void register(List<String> methods);

  // for either to update the expiry of an existing pairing.
  Future<void> updateExpiry({required String topic, required int expiry});

  // for either to update the metadata of an existing pairing.
  Future<void> updateMetadata(
      {required String topic, required AppMetadata metadata});

  // query pairings
  List<PairingStruct> getPairings();

  // for either to ping a peer
  Future<void> ping({required String topic});

  // for either peer to disconnect a pairing
  Future<void> disconnect({required String topic});
}
