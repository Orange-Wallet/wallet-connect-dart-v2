import 'package:example/models/chain_metdata.dart';

class SolanaData {
  static final ChainData mainChains = {
    'solana:4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZ': const ChainMetadata(
        chainId: '4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZ',
        name: 'Solana',
        logo: '/chain-logos/solana-4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZ.png',
        rpc: ''),
  };

  static final ChainData testChains = {
    'solana:8E9rvCKLFQia2Y35HXjjpWzj8weVo44K': const ChainMetadata(
        chainId: '8E9rvCKLFQia2Y35HXjjpWzj8weVo44K',
        name: 'Solana Devnet',
        logo: '/chain-logos/solana-4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZ.png',
        rpc: '')
  };

  static final ChainData chains = {...mainChains, ...testChains};

  final Map<SolanaMethods, String> methods = {
    SolanaMethods.SOLANA_SIGN_TRANSACTION: 'solana_signTransaction',
    SolanaMethods.SOLANA_SIGN_MESSAGE: 'solana_signMessage'
  };
}

enum SolanaMethods { SOLANA_SIGN_TRANSACTION, SOLANA_SIGN_MESSAGE }
