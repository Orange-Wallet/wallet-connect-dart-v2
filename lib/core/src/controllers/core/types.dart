import 'package:logger/logger.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';

class Metadata {
  final String name;
  final String description;
  final String url;
  final List<String> icons;

  Metadata({
    required this.name,
    required this.description,
    required this.url,
    required this.icons,
  });
}

abstract class ICore extends IEvents {
  final String protocol = "wc";
  final int version = 2;

  // public abstract readonly name;
  // public abstract readonly context;
  // public abstract readonly relayUrl?;
  // public abstract readonly projectId?;

  // public abstract logger: Logger;
  // public abstract heartbeat: IHeartBeat;
  // public abstract crypto: ICrypto;
  // public abstract relayer: IRelayer;
  // public abstract storage: IKeyValueStorage;
  // public abstract history: IJsonRpcHistory;
  // public abstract expirer: IExpirer;
  // public abstract pairing: IPairing;

  final String? projectId;
  final String? name;
  final String? relayUrl;
  final Logger? logger;
  final IKeyChain? keychain;
  final IKeyValueStorage? storage;
  final KeyValueStorageOptions? storageOptions;

  ICore({
    this.projectId,
    this.name,
    this.relayUrl,
    this.logger,
    this.keychain,
    this.storage,
    this.storageOptions,
  });

  Future<void> start();
}
