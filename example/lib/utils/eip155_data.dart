import 'package:example/models/chain_metdata.dart';

class Eip155Data {
  static final ChainData mainChains = {
    'eip155:1': const ChainMetadata(
      chainId: '1',
      name: 'Ethereum',
      logo: '/chain-logos/eip155-1.png',
      rpc: ['https://cloudflare-eth.com/'],
    ),
    'eip155:10': const ChainMetadata(
      chainId: '10',
      name: 'Optimism',
      logo: '/chain-logos/eip155-10.png',
      rpc: ['https://mainnet.optimism.io'],
    ),
    'eip155:100': const ChainMetadata(
      chainId: '100',
      name: 'xDai',
      logo: '/chain-logos/eip155-100.png',
      rpc: [],
    ),
    'eip155:137': const ChainMetadata(
      chainId: '137',
      name: 'Polygon',
      logo: '/chain-logos/eip155-137.png',
      rpc: ['https://polygon-rpc.com/'],
    ),
    'eip155:43114': const ChainMetadata(
      chainId: '43114',
      name: 'Avalanche C-Chain',
      logo: '/chain-logos/eip155-43113.png',
      rpc: ['https://api.avax.network/ext/bc/C/rpc'],
    ),
    'eip155:42161': const ChainMetadata(
      chainId: '42161',
      name: 'Arbitrum',
      logo: '/chain-logos/eip155-42161.png',
      rpc: [],
    ),
    'eip155:42220': const ChainMetadata(
      chainId: '42220',
      name: 'Celo',
      logo: '/chain-logos/eip155-42220.png',
      rpc: [],
    ),
  };

  static final ChainData testChains = {
    'eip155:5': const ChainMetadata(
      chainId: '5',
      name: 'Ethereum Goerli',
      logo: '/chain-logos/eip155-1.png',
      rpc: ['https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161'],
    ),
    'eip155:42': const ChainMetadata(
      chainId: '42',
      name: 'Ethereum Kovan',
      logo: '/chain-logos/eip155-1.png',
      rpc: [],
    ),
    'eip155:420': const ChainMetadata(
      chainId: '420',
      name: 'Optimism Goerli',
      logo: '/chain-logos/eip155-10.png',
      rpc: ['https://goerli.optimism.io'],
    ),
    'eip155:80001': const ChainMetadata(
      chainId: '80001',
      name: 'Polygon Mumbai',
      logo: '/chain-logos/eip155-137.png',
      rpc: ['https://matic-mumbai.chainstacklabs.com'],
    ),
    'eip155:43113': const ChainMetadata(
      chainId: '43113',
      name: 'Avalanche Fuji',
      logo: '/chain-logos/eip155-43113.png',
      rpc: ['https://api.avax-test.network/ext/bc/C/rpc'],
    ),
    'eip155:44787': const ChainMetadata(
      chainId: '44787',
      name: 'Celo',
      logo: '/chain-logos/eip155-42220.png',
      rpc: [],
    ),
    'eip155:421611': const ChainMetadata(
      chainId: '421611',
      name: 'Arbitrum',
      logo: '/chain-logos/eip155-42161.png',
      rpc: [],
    ),
  };

  static final ChainData chains = {...mainChains, ...testChains};

  static final Map<Eip155Methods, String> methods = {
    Eip155Methods.PERSONAL_SIGN: 'personal_sign',
    Eip155Methods.ETH_SIGN: 'eth_sign',
    Eip155Methods.ETH_SIGN_TRANSACTION: 'eth_signTransaction',
    Eip155Methods.ETH_SIGN_TYPED_DATA: 'eth_signTypedData',
    Eip155Methods.ETH_SIGN_TYPED_DATA_V3: 'eth_signTypedData_v3',
    Eip155Methods.ETH_SIGN_TYPED_DATA_V4: 'eth_signTypedData_v4',
    Eip155Methods.ETH_SEND_RAW_TRANSACTION: 'eth_sendRawTransaction',
    Eip155Methods.ETH_SEND_TRANSACTION: 'eth_sendTransaction'
  };
}

enum Eip155Methods {
  PERSONAL_SIGN,
  ETH_SIGN,
  ETH_SIGN_TRANSACTION,
  ETH_SIGN_TYPED_DATA,
  ETH_SIGN_TYPED_DATA_V3,
  ETH_SIGN_TYPED_DATA_V4,
  ETH_SEND_RAW_TRANSACTION,
  ETH_SEND_TRANSACTION,
}

extension Eip155MethodsX on Eip155Methods {
  String? get value => Eip155Data.methods[this];
}

extension Eip155MethodsStringX on String {
  Eip155Methods? toEip155Method() {
    final entries =
        Eip155Data.methods.entries.where((element) => element.value == this);
    return (entries.isNotEmpty) ? entries.first.key : null;
  }
}
