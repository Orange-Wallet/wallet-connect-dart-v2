import 'package:logger/logger.dart';
import 'package:wallet_connect/core/core/constants.dart';
import 'package:wallet_connect/core/core/types.dart';
import 'package:wallet_connect/core/crypto/crypto.dart';
import 'package:wallet_connect/core/expirer/expirer.dart';
import 'package:wallet_connect/core/history/types.dart';
import 'package:wallet_connect/core/keychain/types.dart';
import 'package:wallet_connect/core/crypto/types.dart';
import 'package:wallet_connect/core/expirer/types.dart';
import 'package:wallet_connect/core/pairing/pairing.dart';
import 'package:wallet_connect/core/pairing/types.dart';
import 'package:wallet_connect/core/relayer/relayer.dart';
import 'package:wallet_connect/core/relayer/types.dart';
import 'package:wallet_connect/wc_utils/keyvaluestorage/types.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';
import 'package:wallet_connect/wc_utils/misc/heartbeat/heartbeat.dart';
import 'package:wallet_connect/wc_utils/misc/heartbeat/types.dart';

class Core with IEvents implements ICore {
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
  final EventSubject events;

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
  })  : logger = logger ?? Logger(),
        heartbeat = heartbeat ?? HeartBeat(),
        events = EventSubject() {
    crypto = crypto ?? Crypto(core: this, logger: logger);
    //   history = new JsonRpcHistory(this, logger);
    expirer = expirer ?? Expirer(core: this, logger: logger);
    //   storage = opts?.storage
    //     ? opts.storage
    //     : new KeyValueStorage({ ...CORE_STORAGE_OPTIONS, ...opts?.storageOptions });
    relayer = relayer ??
        Relayer(
          core: this,
          logger: logger,
          relayUrl: relayUrl,
          projectId: projectId,
        );
    pairing = pairing ?? Pairing(core: this, logger: logger);
  }

  // ---------- Public ----------------------------------------------- //

  @override
  start() async {
    if (_initialized) return;
    await _initialize();
  }

  // ---------- Private ----------------------------------------------- //

  _initialize() async {
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
    } catch (error) {
      logger.w(
          'Core Initilization Failure at epoch ${DateTime.now().millisecondsSinceEpoch}',
          error);
      logger.e(error.toString());
      rethrow;
    }
  }
}
