import 'dart:developer';

import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:example_wallet/models/accounts.dart';
import 'package:example_wallet/models/ethereum/wc_ethereum_sign_message.dart';
import 'package:example_wallet/models/ethereum/wc_ethereum_transaction.dart';
import 'package:example_wallet/pages/accounts_page.dart';
import 'package:example_wallet/pages/connect_page.dart';
import 'package:example_wallet/pages/pairings_page.dart';
import 'package:example_wallet/pages/sessions_page.dart';
import 'package:example_wallet/pages/settings_page.dart';
import 'package:example_wallet/utils/constants.dart';
import 'package:example_wallet/utils/eip155_data.dart';
import 'package:example_wallet/utils/hd_key_utils.dart';
import 'package:example_wallet/widgets/session_request_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wallet_connect/wallet_connect.dart';
import 'package:wallet_connect/wc_utils/misc/logger/logger.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        colorScheme: const ColorScheme.light().copyWith(
          background: Colors.white,
          primary: primaryColor,
          secondary: secondaryColor,
        ),
      ),
      home: const HomePage(),
    );
  }
}

const primaryColor = Color(0xFFbe5bd8);
const secondaryColor = Color(0xFF0070f2);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final accounts = Constants.accounts;

  final _pageController = PageController(initialPage: 2);

  late int _activePage;

  late bool _initializing;

  late bool _enableScanView;

  final _web3client = Web3Client('', http.Client());

  SignClient? _signClient;

  @override
  void initState() {
    _activePage = _pageController.initialPage;
    _enableScanView = false;
    _initialize();
    super.initState();
  }

  void _initialize() async {
    _initializing = true;
    _signClient = await SignClient.init(
      projectId: "73801621aec60dfaa2197c7640c15858",
      relayUrl: "wss://relay.walletconnect.com",
      metadata: const AppMetadata(
        name: 'Wallet',
        description: 'Wallet for WalletConnect',
        url: 'https://walletconnect.com/',
        icons: ['https://avatars.githubusercontent.com/u/37784886'],
      ),
      database: 'wallet.db',
      logger: Logger(),
    );

    _signClient!.on(SignClientEvent.SESSION_PROPOSAL.value, (data) async {
      final eventData = data as SignClientEventParams<RequestSessionPropose>;
      log('SESSION_PROPOSAL: $eventData');

      setState(() {
        _enableScanView = false;
      });

      _onSessionRequest(eventData.id!, eventData.params!);
    });

    _signClient!.on(SignClientEvent.SESSION_REQUEST.value, (data) async {
      final eventData = data as SignClientEventParams<RequestSessionRequest>;
      log('SESSION_REQUEST: $eventData');
      final session = _signClient!.session.get(eventData.topic!);

      switch (eventData.params!.request.method.toEip155Method()) {
        case Eip155Methods.PERSONAL_SIGN:
          final requestParams =
              (eventData.params!.request.params as List).cast<String>();
          final dataToSign = requestParams[0];
          final address = requestParams[1];
          final message = WCEthereumSignMessage(
            data: dataToSign,
            address: address,
            type: WCSignType.PERSONAL_MESSAGE,
          );
          return _onSign(eventData.id!, eventData.topic!, session, message);
        case Eip155Methods.ETH_SIGN:
          final requestParams =
              (eventData.params!.request.params as List).cast<String>();
          final dataToSign = requestParams[1];
          final address = requestParams[0];
          final message = WCEthereumSignMessage(
            data: dataToSign,
            address: address,
            type: WCSignType.MESSAGE,
          );
          return _onSign(eventData.id!, eventData.topic!, session, message);
        case Eip155Methods.ETH_SIGN_TYPED_DATA:
          final requestParams =
              (eventData.params!.request.params as List).cast<String>();
          final dataToSign = requestParams[1];
          final address = requestParams[0];
          final message = WCEthereumSignMessage(
            data: dataToSign,
            address: address,
            type: WCSignType.TYPED_MESSAGE_V4,
          );
          return _onSign(eventData.id!, eventData.topic!, session, message);
        case Eip155Methods.ETH_SIGN_TYPED_DATA_V3:
          final requestParams =
              (eventData.params!.request.params as List).cast<String>();
          final dataToSign = requestParams[1];
          final address = requestParams[0];
          final message = WCEthereumSignMessage(
            data: dataToSign,
            address: address,
            type: WCSignType.TYPED_MESSAGE_V3,
          );
          return _onSign(eventData.id!, eventData.topic!, session, message);
        case Eip155Methods.ETH_SIGN_TYPED_DATA_V4:
          final requestParams =
              (eventData.params!.request.params as List).cast<String>();
          final dataToSign = requestParams[1];
          final address = requestParams[0];
          final message = WCEthereumSignMessage(
            data: dataToSign,
            address: address,
            type: WCSignType.TYPED_MESSAGE_V4,
          );
          return _onSign(eventData.id!, eventData.topic!, session, message);
        case Eip155Methods.ETH_SIGN_TRANSACTION:
          final ethereumTransaction = WCEthereumTransaction.fromJson(
              eventData.params!.request.params.first);
          return _onSignTransaction(
            eventData.id!,
            int.parse(eventData.params!.chainId.split(':').last),
            session,
            ethereumTransaction,
          );
        case Eip155Methods.ETH_SEND_TRANSACTION:
          final ethereumTransaction = WCEthereumTransaction.fromJson(
              eventData.params!.request.params.first);
          return _onSendTransaction(
            eventData.id!,
            int.parse(eventData.params!.chainId.split(':').last),
            session,
            ethereumTransaction,
          );
        case Eip155Methods.ETH_SEND_RAW_TRANSACTION:
          // TODO
          break;
        default:
          debugPrint('Unsupported request.');
      }
    });

    _signClient!.on(SignClientEvent.SESSION_EVENT.value, (data) async {
      final eventData = data as SignClientEventParams<RequestSessionEvent>;
      log('SESSION_EVENT: $eventData');
    });

    _signClient!.on(SignClientEvent.SESSION_PING.value, (data) async {
      final eventData = data as SignClientEventParams<void>;
      log('SESSION_PING: $eventData');
    });

    _signClient!.on(SignClientEvent.SESSION_DELETE.value, (data) async {
      final eventData = data as SignClientEventParams<void>;
      log('SESSION_DELETE: $eventData');
      _onSessionClosed(9999, 'Ended.');
    });

    setState(() {
      _initializing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      extendBodyBehindAppBar: true,
      body: _initializing
          ? Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() {
                _activePage = page;
              }),
              children: [
                AccountsPage(accounts: accounts),
                SessionsPage(signClient: _signClient!),
                ConnectPage(
                  signClient: _signClient!,
                  enableScanView: _enableScanView,
                ),
                PairingsPage(signClient: _signClient!),
                const SettingsPage(),
              ],
            ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, secondaryColor],
          ),
        ),
        child: FloatingActionButton(
          onPressed: () {
            _pageController.animateToPage(
              2,
              duration: const Duration(milliseconds: 350),
              curve: Curves.ease,
            );
          },
          backgroundColor: Colors.transparent,
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        elevation: 6.0,
        color: Theme.of(context).colorScheme.background,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            BottomNavItem(
              onTap: () {
                _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.ease,
                );
              },
              active: _activePage == 0,
              label: 'Accounts',
              icon: Icons.account_circle_outlined,
            ),
            BottomNavItem(
              onTap: () {
                _pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.ease,
                );
              },
              active: _activePage == 1,
              label: 'Sessions',
              icon: Icons.device_hub,
            ),
            const SizedBox(width: 16.0),
            BottomNavItem(
              onTap: () {
                _pageController.animateToPage(
                  3,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.ease,
                );
              },
              active: _activePage == 3,
              label: 'Pairings',
              icon: Icons.link,
            ),
            BottomNavItem(
              onTap: () {
                _pageController.animateToPage(
                  4,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.ease,
                );
              },
              active: _activePage == 4,
              label: 'Settings',
              icon: Icons.settings_outlined,
            ),
          ],
        ),
      ),
    );
  }

  _onSessionRequest(int id, RequestSessionPropose proposal) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: SessionRequestView(
          accounts: accounts,
          proposal: proposal,
          onApprove: (namespaces) async {
            final params = SessionApproveParams(
              id: id,
              namespaces: namespaces,
            );
            //  final approved = await
            _signClient!.approve(params);
            // await approved.acknowledged;
            Navigator.pop(context);
          },
          onReject: () {
            _signClient!.reject(SessionRejectParams(
              id: id,
              reason: getSdkError(SdkErrorKey.USER_DISCONNECTED),
            ));
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  _onSessionClosed(int? code, String? reason) {
    showDialog(
      context: context,
      builder: (_) {
        return SimpleDialog(
          title: const Text("Session Ended"),
          contentPadding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('Some Error Occured. ERROR CODE: $code'),
            ),
            if (reason != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('Failure Reason: $reason'),
              ),
            Row(
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('CLOSE'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  _onSignTransaction(
    int id,
    int chainId,
    SessionStruct session,
    WCEthereumTransaction ethereumTransaction,
  ) {
    _onTransaction(
      id: id,
      session: session,
      ethereumTransaction: ethereumTransaction,
      title: 'Sign Transaction',
      onConfirm: () async {
        final account = _getAccountFromAddr(ethereumTransaction.from);
        final privateKey = HDKeyUtils.getPrivateKey(account.mnemonic);
        final creds = EthPrivateKey.fromHex(privateKey);
        final signedTx = await _web3client.signTransaction(
          creds,
          _wcEthTxToWeb3Tx(ethereumTransaction),
          chainId: chainId,
        );
        final signedTxHex = bytesToHex(signedTx, include0x: true);
        _signClient!
            .respond(
          SessionRespondParams(
            topic: session.topic,
            response: JsonRpcResult<String>(
              id: id,
              result: signedTxHex,
            ),
          ),
        )
            .then((value) {
          Navigator.pop(context);
        });
      },
      onReject: () {
        _signClient!
            .respond(SessionRespondParams(
          topic: session.topic,
          response: JsonRpcError(id: id),
        ))
            .then((value) {
          Navigator.pop(context);
        });
      },
    );
  }

  _onSendTransaction(
    int id,
    int chainId,
    SessionStruct session,
    WCEthereumTransaction ethereumTransaction,
  ) {
    _onTransaction(
      id: id,
      session: session,
      ethereumTransaction: ethereumTransaction,
      title: 'Send Transaction',
      onConfirm: () async {
        final account = _getAccountFromAddr(ethereumTransaction.from);
        final privateKey = HDKeyUtils.getPrivateKey(account.mnemonic);
        final creds = EthPrivateKey.fromHex(privateKey);
        final txHash = await _web3client.sendTransaction(
          creds,
          _wcEthTxToWeb3Tx(ethereumTransaction),
          chainId: chainId,
        );
        debugPrint('txHash $txHash');
        _signClient!
            .respond(
          SessionRespondParams(
            topic: session.topic,
            response: JsonRpcResult<String>(
              id: id,
              result: txHash,
            ),
          ),
        )
            .then((value) {
          Navigator.pop(context);
        });
      },
      onReject: () {
        _signClient!
            .respond(SessionRespondParams(
          topic: session.topic,
          response: JsonRpcError(id: id),
        ))
            .then((value) {
          Navigator.pop(context);
        });
      },
    );
  }

  _onTransaction({
    required int id,
    required SessionStruct session,
    required WCEthereumTransaction ethereumTransaction,
    required String title,
    required VoidCallback onConfirm,
    required VoidCallback onReject,
  }) async {
    BigInt gasPrice = BigInt.parse(ethereumTransaction.gasPrice ?? '0');
    if (gasPrice == BigInt.zero) {
      gasPrice = await _web3client.estimateGas();
    }
    showDialog(
      context: context,
      builder: (_) {
        return SimpleDialog(
          title: Column(
            children: [
              if (session.peer.metadata.icons.isNotEmpty)
                Container(
                  height: 100.0,
                  width: 100.0,
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Image.network(session.peer.metadata.icons.first),
                ),
              Text(
                session.peer.metadata.name,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 20.0,
                ),
              ),
            ],
          ),
          contentPadding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Receipient',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '${ethereumTransaction.to}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'Transaction Fee',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${(EtherAmount.fromUnitAndValue(EtherUnit.wei, ethereumTransaction.maxFeePerGas ?? ethereumTransaction.gasPrice).getInEther) * BigInt.parse(ethereumTransaction.gas ?? '0')} ETH',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'Transaction Amount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${EtherAmount.fromUnitAndValue(EtherUnit.wei, ethereumTransaction.value).getInEther} ETH',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
            ),
            Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text(
                    'Data',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  children: [
                    Text(
                      '${ethereumTransaction.data}',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: onConfirm,
                    child: const Text('CONFIRM'),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: onReject,
                    child: const Text('REJECT'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  _onSign(
    int id,
    String topic,
    SessionStruct session,
    WCEthereumSignMessage message,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return SimpleDialog(
          title: Column(
            children: [
              if (session.peer.metadata.icons.isNotEmpty)
                Container(
                  height: 100.0,
                  width: 100.0,
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Image.network(session.peer.metadata.icons.first),
                ),
              Text(
                session.peer.metadata.name,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 20.0,
                ),
              ),
            ],
          ),
          contentPadding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(bottom: 8.0),
              child: const Text(
                'Sign Message',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text(
                    'Message',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  children: [
                    Text(
                      message.data,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: () async {
                      final account = _getAccountFromAddr(message.address);
                      final privateKey =
                          HDKeyUtils.getPrivateKey(account.mnemonic);
                      final creds = EthPrivateKey.fromHex(privateKey);
                      String signedDataHex;
                      if (message.type == WCSignType.TYPED_MESSAGE_V1) {
                        signedDataHex = EthSigUtil.signTypedData(
                          privateKey: privateKey,
                          jsonData: message.data,
                          version: TypedDataVersion.V1,
                        );
                      } else if (message.type == WCSignType.TYPED_MESSAGE_V3) {
                        signedDataHex = EthSigUtil.signTypedData(
                          privateKey: privateKey,
                          jsonData: message.data,
                          version: TypedDataVersion.V3,
                        );
                      } else if (message.type == WCSignType.TYPED_MESSAGE_V4) {
                        signedDataHex = EthSigUtil.signTypedData(
                          privateKey: privateKey,
                          jsonData: message.data,
                          version: TypedDataVersion.V4,
                        );
                      } else {
                        final encodedMessage = hexToBytes(message.data);
                        final signedData =
                            await creds.signPersonalMessage(encodedMessage);
                        signedDataHex = bytesToHex(signedData, include0x: true);
                      }
                      debugPrint('SIGNED $signedDataHex');
                      _signClient!
                          .respond(
                        SessionRespondParams(
                          topic: topic,
                          response: JsonRpcResult<String>(
                            id: id,
                            result: signedDataHex,
                          ),
                        ),
                      )
                          .then((value) {
                        Navigator.pop(context);
                      });
                    },
                    child: const Text('SIGN'),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: () {
                      _signClient!
                          .respond(SessionRespondParams(
                        topic: session.topic,
                        response: JsonRpcError(id: id),
                      ))
                          .then((value) {
                        Navigator.pop(context);
                      });
                    },
                    child: const Text('REJECT'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Account _getAccountFromAddr(String address) {
    return accounts
        .where((element) => element.details.any((element) =>
            element.address.toLowerCase() == address.toLowerCase()))
        .first;
  }

  Transaction _wcEthTxToWeb3Tx(WCEthereumTransaction ethereumTransaction) {
    return Transaction(
      from: EthereumAddress.fromHex(ethereumTransaction.from),
      to: EthereumAddress.fromHex(ethereumTransaction.to!),
      maxGas: ethereumTransaction.gasLimit != null
          ? int.tryParse(ethereumTransaction.gasLimit!)
          : null,
      gasPrice: ethereumTransaction.gasPrice != null
          ? EtherAmount.inWei(BigInt.parse(ethereumTransaction.gasPrice!))
          : null,
      value: EtherAmount.inWei(BigInt.parse(ethereumTransaction.value ?? '0')),
      data: hexToBytes(ethereumTransaction.data!),
      nonce: ethereumTransaction.nonce != null
          ? int.tryParse(ethereumTransaction.nonce!)
          : null,
      maxFeePerGas: ethereumTransaction.maxFeePerGas != null
          ? EtherAmount.inWei(BigInt.parse(ethereumTransaction.maxFeePerGas!))
          : null,
      maxPriorityFeePerGas: ethereumTransaction.maxPriorityFeePerGas != null
          ? EtherAmount.inWei(
              BigInt.parse(ethereumTransaction.maxPriorityFeePerGas!))
          : null,
    );
  }
}

class BottomNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const BottomNavItem({
    Key? key,
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.secondary.withOpacity(0.7),
            ),
            const SizedBox(height: 8.0),
            Text(
              label,
              style: TextStyle(
                color: active
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.secondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
