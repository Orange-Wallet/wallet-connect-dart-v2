import 'package:logger/logger.dart';
import 'package:wallet_connect/core/constants.dart';
import 'package:wallet_connect/core/crypto/crypto.dart';
import 'package:wallet_connect/core/crypto/i_crypto.dart';
import 'package:wallet_connect/core/expirer/expirer.dart';
import 'package:wallet_connect/core/expirer/i_expirer.dart';
import 'package:wallet_connect/core/history/history.dart';
import 'package:wallet_connect/core/history/models.dart';
import 'package:wallet_connect/core/i_core.dart';
import 'package:wallet_connect/core/keychain/i_key_chain.dart';
import 'package:wallet_connect/core/pairing/i_pairing.dart';
import 'package:wallet_connect/core/pairing/pairing.dart';
import 'package:wallet_connect/core/relayer/i_relayer.dart';
import 'package:wallet_connect/core/relayer/relayer.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';
import 'package:wallet_connect/wc_utils/misc/heartbeat/heartbeat.dart';
import 'package:wallet_connect/wc_utils/misc/heartbeat/i_heart_beat.dart';
import 'package:wallet_connect/wc_utils/misc/keyvaluestorage/key_value_storage.dart';
import 'package:wallet_connect/wc_utils/misc/keyvaluestorage/i_key_value_storage.dart';

class Core with Events implements ICore {
  @override
  final String protocol = CORE_PROTOCOL;

  @override
  final int version = CORE_VERSION;

  @override
  final String name = CORE_CONTEXT;

  @override
  final String? relayUrl;

  @override
  final String? projectId;

  @override
  final EventEmitter<String> events;

  @override
  final Logger logger;

  @override
  final IHeartBeat heartbeat;

  @override
  late final ICrypto crypto;

  @override
  late final IRelayer relayer;

  @override
  late final IKeyValueStorage storage;

  @override
  late final IJsonRpcHistory history;

  @override
  late final IExpirer expirer;

  @override
  late final IPairing pairing;

  bool _initialized = false;

  Core({
    this.projectId,
    this.relayUrl,
    Logger? logger,
    IKeyChain? keychain,
    IHeartBeat? heartbeat,
    ICrypto? crypto,
    IJsonRpcHistory? history,
    IExpirer? expirer,
    IRelayer? relayer,
    IPairing? pairing,
    IKeyValueStorage? storage,
    String? database,
  })  : logger = logger ?? Logger(),
        heartbeat = heartbeat ?? HeartBeat(),
        events = EventEmitter() {
    this.crypto = crypto ?? Crypto(core: this, logger: logger);
    this.history = history ?? JsonRpcHistory(core: this, logger: logger);
    this.expirer = expirer ?? Expirer(core: this, logger: logger);
    this.storage = storage ??
        KeyValueStorage(
          database: database ?? CoreStorageOptions.database,
        );
    this.relayer = relayer ??
        Relayer(
          core: this,
          logger: logger,
          relayUrl: relayUrl,
          projectId: projectId,
        );
    this.pairing = pairing ?? Pairing(core: this, logger: logger);
  }

  // ---------- Public ----------------------------------------------- //

  @override
  Future<void> start() async {
    if (_initialized) return;
    await _initialize();
  }

  // ---------- Private ----------------------------------------------- //

  Future<void> _initialize() async {
    logger.i('Initialized');
    try {
      await crypto.init();
      await history.init();
      await expirer.init();
      await relayer.init();
      await heartbeat.init();
      await pairing.init();
      _initialized = true;
      logger.i('Core Initilization Success');
    } catch (error, trace) {
      logger.w(
          'Core Initilization Failure at epoch ${DateTime.now().millisecondsSinceEpoch}',
          error);
      logger.e(trace.toString());
      rethrow;
    }
  }
}
