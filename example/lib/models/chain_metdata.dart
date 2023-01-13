class ChainMetadata {
  final String chainId;
  final String name;
  final String logo;
  final String rpc;

  const ChainMetadata({
    required this.chainId,
    required this.name,
    required this.logo,
    required this.rpc,
  });
}

typedef ChainData = Map<String, ChainMetadata>;
