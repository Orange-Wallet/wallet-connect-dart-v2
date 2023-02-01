import 'package:example_dapp/models/chain_metadata.dart';

class SolanaData {
  static const List<ChainMetadata> mainChains = [
    ChainMetadata(
      chainId: 'solana:4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZ',
      name: 'Solana',
      logo: '/chain-logos/solana-4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZ.png',
      rpc: [
        "https://api.mainnet-beta.solana.com",
        "https://solana-api.projectserum.com",
      ],
    ),
  ];

  static const List<ChainMetadata> testChains = [
    ChainMetadata(
      chainId: 'solana:8E9rvCKLFQia2Y35HXjjpWzj8weVo44K',
      name: 'Solana Devnet',
      logo: '/chain-logos/solana-4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZ.png',
      rpc: ["https://api.devnet.solana.com"],
    )
  ];

  static const List<ChainMetadata> chains = [...mainChains, ...testChains];

  static final Map<SolanaMethods, String> methods = {
    SolanaMethods.SOLANA_SIGN_TRANSACTION: 'solana_signTransaction',
    SolanaMethods.SOLANA_SIGN_MESSAGE: 'solana_signMessage'
  };

  static final Map<dynamic, String> events = {};
}

enum SolanaMethods { SOLANA_SIGN_TRANSACTION, SOLANA_SIGN_MESSAGE }
