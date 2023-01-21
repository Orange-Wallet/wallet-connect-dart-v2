import 'package:example/models/accounts.dart';

class Constants {
  static const List<Account> accounts = [
    Account(
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
          address: '9UHaMxmfS2eaLCDTxwCU2ok3ReofvgdhxxRtLum7KKf5',
          chain: 'solana:4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZ',
        ),
      ],
    ),
    Account(
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
          address: '84ha8EZUTwpj36VTe8TzZU6oWz3qn2Yghw7FTxsBm6dr',
          chain: 'solana:4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZ',
        ),
      ],
    ),
  ];
}
