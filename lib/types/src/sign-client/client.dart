abstract class ISignClient {
  final protocol = "wc";
  final version = 2;

  final String name;
  final String context;
  final SignClientTypes.Metadata metadata;

  final ICore core;
  final Logger logger;
  final ISignClientEvents events;
  final IEngine engine;
  final ISession session;
  final IProposal proposal;

  ISignClient( {SignClientTypes.Options? opts}) ;

  public abstract connect: IEngine["connect"];
  public abstract pair: IEngine["pair"];
  public abstract approve: IEngine["approve"];
  public abstract reject: IEngine["reject"];
  public abstract update: IEngine["update"];
  public abstract extend: IEngine["extend"];
  public abstract request: IEngine["request"];
  public abstract respond: IEngine["respond"];
  public abstract ping: IEngine["ping"];
  public abstract emit: IEngine["emit"];
  public abstract disconnect: IEngine["disconnect"];
  public abstract find: IEngine["find"];
}