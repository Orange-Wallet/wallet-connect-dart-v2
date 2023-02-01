import 'package:example_dapp/models/accounts.dart';

class Constants {
  static const List<Account> accounts = [
    Account(
      id: 0,
      name: 'Account 1',
      mnemonic:
          'opinion obscure meat unfold win defense good rice hero light enrich menu',
      privateKey: '',
      details: [
        AccountDetails(
          address: '0x516D18c6b8f7f18b4Ce721c8435651427a652487',
          chain: 'eip155:1',
        ),
        AccountDetails(
          address: '0x516D18c6b8f7f18b4Ce721c8435651427a652487',
          chain: 'eip155:10',
        ),
        AccountDetails(
          address: '0x516D18c6b8f7f18b4Ce721c8435651427a652487',
          chain: 'eip155:100',
        ),
        AccountDetails(
          address: '0x516D18c6b8f7f18b4Ce721c8435651427a652487',
          chain: 'eip155:137',
        ),
        AccountDetails(
          address: '0x516D18c6b8f7f18b4Ce721c8435651427a652487',
          chain: 'eip155:42161',
        ),
        AccountDetails(
          address: '0x516D18c6b8f7f18b4Ce721c8435651427a652487',
          chain: 'eip155:43114',
        ),
        AccountDetails(
          address: '0x516D18c6b8f7f18b4Ce721c8435651427a652487',
          chain: 'eip155:42220',
        ),
        AccountDetails(
          address: '9UHaMxmfS2eaLCDTxwCU2ok3ReofvgdhxxRtLum7KKf5',
          chain: 'solana:4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZ',
        ),
      ],
    ),
    Account(
      id: 1,
      name: 'Account 2',
      mnemonic:
          'civil street solution planet live anchor rate click obscure error oblige account',
      privateKey: '',
      details: [
        AccountDetails(
          address: '0x6455aD57e7819062201aEc706D247507194ed238',
          chain: 'eip155:1',
        ),
        AccountDetails(
          address: '0x6455aD57e7819062201aEc706D247507194ed238',
          chain: 'eip155:10',
        ),
        AccountDetails(
          address: '0x6455aD57e7819062201aEc706D247507194ed238',
          chain: 'eip155:100',
        ),
        AccountDetails(
          address: '0x6455aD57e7819062201aEc706D247507194ed238',
          chain: 'eip155:137',
        ),
        AccountDetails(
          address: '0x6455aD57e7819062201aEc706D247507194ed238',
          chain: 'eip155:42161',
        ),
        AccountDetails(
          address: '0x6455aD57e7819062201aEc706D247507194ed238',
          chain: 'eip155:43114',
        ),
        AccountDetails(
          address: '0x6455aD57e7819062201aEc706D247507194ed238',
          chain: 'eip155:42220',
        ),
        AccountDetails(
          address: '84ha8EZUTwpj36VTe8TzZU6oWz3qn2Yghw7FTxsBm6dr',
          chain: 'solana:4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZ',
        ),
      ],
    ),
  ];

  static const List<Account> testnetAccounts = [
    Account(
      id: 0,
      name: 'Account 1',
      mnemonic:
          'opinion obscure meat unfold win defense good rice hero light enrich menu',
      privateKey: '',
      details: [
        AccountDetails(
          address: '0x516D18c6b8f7f18b4Ce721c8435651427a652487',
          chain: 'eip155:5',
        ),
        AccountDetails(
          address: '0x516D18c6b8f7f18b4Ce721c8435651427a652487',
          chain: 'eip155:42',
        ),
        AccountDetails(
          address: '0x516D18c6b8f7f18b4Ce721c8435651427a652487',
          chain: 'eip155:420',
        ),
        AccountDetails(
          address: '0x516D18c6b8f7f18b4Ce721c8435651427a652487',
          chain: 'eip155:80001',
        ),
        AccountDetails(
          address: '0x516D18c6b8f7f18b4Ce721c8435651427a652487',
          chain: 'eip155:43113',
        ),
        AccountDetails(
          address: '0x516D18c6b8f7f18b4Ce721c8435651427a652487',
          chain: 'eip155:44787',
        ),
        AccountDetails(
          address: '0x516D18c6b8f7f18b4Ce721c8435651427a652487',
          chain: 'eip155:421611',
        ),
        AccountDetails(
          address: '9UHaMxmfS2eaLCDTxwCU2ok3ReofvgdhxxRtLum7KKf5',
          chain: 'solana:8E9rvCKLFQia2Y35HXjjpWzj8weVo44K',
        ),
      ],
    ),
    Account(
      id: 1,
      name: 'Account 2',
      mnemonic:
          'civil street solution planet live anchor rate click obscure error oblige account',
      privateKey: '',
      details: [
        AccountDetails(
          address: '0x6455aD57e7819062201aEc706D247507194ed238',
          chain: 'eip155:5',
        ),
        AccountDetails(
          address: '0x6455aD57e7819062201aEc706D247507194ed238',
          chain: 'eip155:42',
        ),
        AccountDetails(
          address: '0x6455aD57e7819062201aEc706D247507194ed238',
          chain: 'eip155:420',
        ),
        AccountDetails(
          address: '0x6455aD57e7819062201aEc706D247507194ed238',
          chain: 'eip155:80001',
        ),
        AccountDetails(
          address: '0x6455aD57e7819062201aEc706D247507194ed238',
          chain: 'eip155:43113',
        ),
        AccountDetails(
          address: '0x6455aD57e7819062201aEc706D247507194ed238',
          chain: 'eip155:44787',
        ),
        AccountDetails(
          address: '0x6455aD57e7819062201aEc706D247507194ed238',
          chain: 'eip155:421611',
        ),
        AccountDetails(
          address: '84ha8EZUTwpj36VTe8TzZU6oWz3qn2Yghw7FTxsBm6dr',
          chain: 'solana:8E9rvCKLFQia2Y35HXjjpWzj8weVo44K',
        ),
      ],
    ),
  ];
}
