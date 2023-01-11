import 'package:logger/logger.dart';
import 'package:wallet_connect/core/core.dart';
import 'package:wallet_connect/core/i_core.dart';
import 'package:wallet_connect/core/models/app_metadata.dart';
import 'package:wallet_connect/core/pairing/types.dart';
import 'package:wallet_connect/core/store/i_store.dart';
import 'package:wallet_connect/sign/engine/engine.dart';
import 'package:wallet_connect/sign/engine/types.dart';
import 'package:wallet_connect/sign/sign-client/client/constants.dart';
import 'package:wallet_connect/sign/sign-client/client/types.dart';
import 'package:wallet_connect/sign/sign-client/pendingRequest/pending_request.dart';
import 'package:wallet_connect/sign/sign-client/pendingRequest/types.dart';
import 'package:wallet_connect/sign/sign-client/proposal/proposal.dart';
import 'package:wallet_connect/sign/sign-client/proposal/types.dart';
import 'package:wallet_connect/sign/sign-client/session/session.dart';
import 'package:wallet_connect/sign/sign-client/session/types.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/types.dart';
import 'package:wallet_connect/wc_utils/misc/events/events.dart';

class SignClient with Events implements ISignClient {
  final String protocol = SIGN_CLIENT_PROTOCOL;
  final int version = SIGN_CLIENT_VERSION;

  @override
  final String name;
  @override
  final AppMetadata metadata;

  @override
  final ICore core;
  @override
  final Logger logger;
  @override
  final EventEmitter<String> events;
  @override
  late final IEngine engine;
  @override
  late final ISession session;
  @override
  late final IProposal proposal;
  @override
  late final IPendingRequest pendingRequest;

  SignClient._({
    String? name,
    required String projectId,
    String? relayUrl,
    required this.metadata,
    ICore? core,
    Level? logLevel,
    String? database,
  })  : name = name ?? SignClientDefault.name,
        events = EventEmitter(),
        core = core ??
            Core(
              projectId: projectId,
              relayUrl: relayUrl,
              database: database,
            ),
        logger = Logger(
          printer: PrefixPrinter(PrettyPrinter(colors: false)),
          level: logLevel ?? Level.info,
        ) {
    engine = Engine(client: this);
    session = Session(core: this.core, logger: logger);
    proposal = Proposal(core: this.core, logger: logger);
    pendingRequest = PendingRequest(core: this.core, logger: logger);
  }

  static Future<SignClient> init({
    String? name,
    required String projectId,
    String? relayUrl,
    AppMetadata? metadata,
    ICore? core,
    Level? logLevel,
    String? database,
  }) async {
    final client = SignClient._(
      name: name,
      projectId: projectId,
      relayUrl: relayUrl,
      metadata: metadata ?? AppMetadata.empty(),
      core: core,
      logLevel: logLevel,
      database: database,
    );
    await client._initialize();
    return client;
  }

  // constructor(opts?: SignClientTypes.Options) {
  //   super(opts);

  //   name = opts?.name || SignClientDefault.name;
  //   metadata = opts?.metadata || getAppMetadata();

  //   const logger =
  //     typeof opts?.logger !== "undefined" && typeof opts?.logger !== "string"
  //       ? opts.logger
  //       : pino(getDefaultLoggerOptions({ level: opts?.logger || SignClientDefault.logger }));

  //   core = opts?.core || new Core(opts);
  //   logger = generateChildLogger(logger, name);
  //   session = new Session(core, logger);
  //   proposal = new Proposal(core, logger);
  //   pendingRequest = new PendingRequest(core, logger);
  //   engine = new Engine(this);
  // }

  IStore<String, PairingTypesStruct> get pairing => core.pairing.pairings;

  // ---------- Events ----------------------------------------------- //

  // public on: ISignClientEvents["on"] = (name, listener) => {
  //   return events.on(name, listener);
  // };

  // public once: ISignClientEvents["once"] = (name, listener) => {
  //   return events.once(name, listener);
  // };

  // public off: ISignClientEvents["off"] = (name, listener) => {
  //   return events.off(name, listener);
  // };

  // public removeListener: ISignClientEvents["removeListener"] = (name, listener) => {
  //   return events.removeListener(name, listener);
  // };

  // public removeAllListeners: ISignClientEvents["removeAllListeners"] = (name) => {
  //   return events.removeAllListeners(name);
  // };

  // ---------- Engine ----------------------------------------------- //

  @override
  Future<EngineTypesConnection> connect(SessionConnectParams params) async {
    try {
      return await engine.connect(params);
    } catch (error) {
      logger.e(error is ErrorResponse ? error.message : error.toString());
      rethrow;
    }
  }

  @override
  Future<PairingTypesStruct> pair(String uri) async {
    try {
      return await engine.pair(uri);
    } catch (error) {
      logger.e(error is ErrorResponse ? error.message : error.toString());
      rethrow;
    }
  }

  @override
  Future<EngineTypesApproved> approve(SessionApproveParams params) async {
    try {
      return await engine.approve(params);
    } catch (error) {
      logger.e(error is ErrorResponse ? error.message : error.toString());
      rethrow;
    }
  }

  @override
  Future<void> reject(SessionRejectParams params) async {
    try {
      return await engine.reject(params);
    } catch (error) {
      logger.e(error is ErrorResponse ? error.message : error.toString());
      rethrow;
    }
  }

  @override
  Future<EngineTypesAcknowledged> update(SessionUpdateParams params) async {
    try {
      return engine.update(params);
    } catch (error) {
      logger.e(error is ErrorResponse ? error.message : error.toString());
      rethrow;
    }
  }

  @override
  Future<EngineTypesAcknowledged> extend(String topic) async {
    try {
      return engine.extend(topic);
    } catch (error) {
      logger.e(error is ErrorResponse ? error.message : error.toString());
      rethrow;
    }
  }

  @override
  Future<T> request<T>(SessionRequestParams params) async {
    try {
      return await engine.request<T>(params);
    } catch (error) {
      logger.e(error is ErrorResponse ? error.message : error.toString());
      rethrow;
    }
  }

  @override
  Future<void> respond(SessionRespondParams params) async {
    try {
      return await engine.respond(params);
    } catch (error) {
      logger.e(error is ErrorResponse ? error.message : error.toString());
      rethrow;
    }
  }

  @override
  Future<void> ping(String topic) async {
    try {
      return await engine.ping(topic);
    } catch (error) {
      logger.e(error is ErrorResponse ? error.message : error.toString());
      rethrow;
    }
  }

  @override
  Future<void> emit(SessionEmitParams params) async {
    try {
      return await engine.emit(params);
    } catch (error) {
      logger.e(error is ErrorResponse ? error.message : error.toString());
      rethrow;
    }
  }

  @override
  Future<void> disconnect({
    required String topic,
    ErrorResponse? reason,
  }) async {
    try {
      return await engine.disconnect(
        topic: topic,
        reason: reason,
      );
    } catch (error) {
      logger.e(error is ErrorResponse ? error.message : error.toString());
      rethrow;
    }
  }

  @override
  List<SessionTypesStruct> find(params) {
    try {
      return engine.find(params);
    } catch (error) {
      logger.e(error is ErrorResponse ? error.message : error.toString());
      rethrow;
    }
  }

  @override
  List<PendingRequestTypesStruct> getPendingSessionRequests() {
    try {
      return engine.getPendingSessionRequests();
    } catch (error) {
      logger.e(error is ErrorResponse ? error.message : error.toString());
      rethrow;
    }
  }

  // ---------- Private ----------------------------------------------- //

  Future<void> _initialize() async {
    logger.i('Initialized');
    try {
      await core.start();
      await session.init();
      await proposal.init();
      await pendingRequest.init();
      await engine.init();
      logger.i('SignClient Initilization Success');
    } catch (error) {
      logger.i('SignClient Initilization Failure');
      logger.e(error is ErrorResponse ? error.message : error.toString());
      rethrow;
    }
  }
}
