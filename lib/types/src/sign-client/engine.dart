import 'package:wallet_connect/types/src/sign-client/client.dart';

abstract class IEngine {
  IEngine(ISignClient client) ;

  Future<void> init();

  public abstract connect(
    params: ConnectParams,
  ): Promise<{ uri?: string; approval: () => Promise<SessionTypes.Struct> }>;

  public abstract pair(params: PairParams): Promise<PairingTypes.Struct>;

  public abstract approve(
    params: ApproveParams,
  ): Promise<{ topic: string; acknowledged: () => Promise<SessionTypes.Struct> }>;

 Future<void> reject(params: RejectParams);

  public abstract update(params: UpdateParams): AcknowledgedPromise;

  public abstract extend(params: ExtendParams): AcknowledgedPromise;

  public abstract request<T>(params: RequestParams): Promise<T>;

 Future<void> respond(params: RespondParams);

 Future<void> emit(params: EmitParams);

 Future<void> ping(params: PingParams);

 Future<void> disconnect(params: DisconnectParams);

  public abstract find: (params: FindParams) => SessionTypes.Struct[];
}