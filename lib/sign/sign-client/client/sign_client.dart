import 'package:logger/logger.dart';
import 'package:wallet_connect_dart_v2/core/core.dart';
import 'package:wallet_connect_dart_v2/core/i_core.dart';
import 'package:wallet_connect_dart_v2/core/models/app_metadata.dart';
import 'package:wallet_connect_dart_v2/core/pairing/models.dart';
import 'package:wallet_connect_dart_v2/core/store/i_store.dart';
import 'package:wallet_connect_dart_v2/sign/engine/engine.dart';
import 'package:wallet_connect_dart_v2/sign/engine/i_engine.dart';
import 'package:wallet_connect_dart_v2/sign/engine/models.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/client/constants.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/client/i_sign_client.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/pending_request/i_pending_request.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/pending_request/models.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/pending_request/pending_request.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/proposal/i_proposal.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/proposal/proposal.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/session/i_session.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/session/models.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/session/session.dart';
import 'package:wallet_connect_dart_v2/wc_utils/jsonrpc/models/models.dart';
import 'package:wallet_connect_dart_v2/wc_utils/misc/events/events.dart';

class SignClient with Events implements ISignClient {
  final String protocol = SIGN_CLIENT_PROTOCOL;

  final int version = SIGN_CLIENT_VERSION;

  @override
  final String name;

  @override
  final AppMetadata metadata;

  @override
  late final ICore core;

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
    Logger? logger,
    String? database,
  })  : name = name ?? SignClientDefault.name,
        events = EventEmitter(),
        logger = logger ??
            Logger(
              printer: PrefixPrinter(PrettyPrinter(colors: false)),
              level: Level.info,
            ) {
    this.core = core ??
        Core(
          projectId: projectId,
          relayUrl: relayUrl,
          database: database,
          logger: logger,
        );
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
    Logger? logger,
    String? database,
  }) async {
    final client = SignClient._(
      name: name,
      projectId: projectId,
      relayUrl: relayUrl,
      metadata: metadata ?? AppMetadata.empty(),
      core: core,
      logger: logger,
      database: database,
    );
    await client._initialize();
    return client;
  }

  IStore<String, PairingStruct> get pairing => core.pairing.pairings;

  // ---------- Engine ----------------------------------------------- //

  @override
  Future<EngineConnection> connect(SessionConnectParams params) {
    try {
      return engine.connect(params);
    } catch (error) {
      logger.e(error is ErrorResponse ? error.message : error.toString());
      rethrow;
    }
  }

  @override
  Future<PairingStruct> pair(String uri) {
    try {
      return engine.pair(uri);
    } catch (error) {
      logger.e(error is ErrorResponse ? error.message : error.toString());
      rethrow;
    }
  }

  @override
  Future<EngineApproved> approve(SessionApproveParams params) {
    try {
      return engine.approve(params);
    } catch (error) {
      logger.e(error is ErrorResponse ? error.message : error.toString());
      rethrow;
    }
  }

  @override
  Future<void> reject(SessionRejectParams params) {
    try {
      return engine.reject(params);
    } catch (error) {
      logger.e(error is ErrorResponse ? error.message : error.toString());
      rethrow;
    }
  }

  @override
  Future<EngineAcknowledged> update(SessionUpdateParams params) {
    try {
      return engine.update(params);
    } catch (error) {
      logger.e(error is ErrorResponse ? error.message : error.toString());
      rethrow;
    }
  }

  @override
  Future<EngineAcknowledged> extend(String topic) {
    try {
      return engine.extend(topic);
    } catch (error) {
      logger.e(error is ErrorResponse ? error.message : error.toString());
      rethrow;
    }
  }

  @override
  Future<T> request<T>(SessionRequestParams params) {
    try {
      return engine.request<T>(params);
    } catch (error) {
      logger.e(error is ErrorResponse ? error.message : error.toString());
      rethrow;
    }
  }

  @override
  Future<void> respond(SessionRespondParams params) {
    try {
      return engine.respond(params);
    } catch (error) {
      logger.e(error is ErrorResponse ? error.message : error.toString());
      rethrow;
    }
  }

  @override
  Future<void> ping(String topic) {
    try {
      return engine.ping(topic);
    } catch (error) {
      logger.e(error is ErrorResponse ? error.message : error.toString());
      rethrow;
    }
  }

  @override
  Future<void> emit(SessionEmitParams params) {
    try {
      return engine.emit(params);
    } catch (error) {
      logger.e(error is ErrorResponse ? error.message : error.toString());
      rethrow;
    }
  }

  @override
  Future<void> disconnect({
    required String topic,
    ErrorResponse? reason,
  }) {
    try {
      return engine.disconnect(
        topic: topic,
        reason: reason,
      );
    } catch (error) {
      logger.e(error is ErrorResponse ? error.message : error.toString());
      rethrow;
    }
  }

  @override
  List<SessionStruct> find(params) {
    try {
      return engine.find(params);
    } catch (error) {
      logger.e(error is ErrorResponse ? error.message : error.toString());
      rethrow;
    }
  }

  @override
  List<PendingRequestStruct> getPendingSessionRequests() {
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
