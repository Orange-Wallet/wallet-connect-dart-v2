
  typedef Expiry = int;

  class BaseNamespace {
    final List<String>? accounts;
    final List<String>? methods;
    final List<String>? events;

  BaseNamespace({this.accounts, this.methods, this.events});
  }

  class Namespace extends BaseNamespace {
     List<BaseNamespace>? extension;
  }

  typedef Namespaces = Map<String, Namespace>;

  class Struct {
     String topic ;
     RelayerTypes.ProtocolOptions relay ;
     Expiry expiry ;
     bool acknowledged ;
     String controller ;
     Namespaces namespaces ;
     ProposalTypes.RequiredNamespaces requiredNamespaces ;
    self: {
      publicKey: string;
      metadata: SignClientTypes.Metadata;
    };
    peer: {
      publicKey: string;
      metadata: SignClientTypes.Metadata;
    };
  }
