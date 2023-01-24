import 'dart:developer';

import 'package:example/models/ethereum/wc_ethereum_sign_message.dart';
import 'package:example/pages/accounts_page.dart';
import 'package:example/pages/connect_page.dart';
import 'package:example/pages/pairings_page.dart';
import 'package:example/pages/sessions_page.dart';
import 'package:example/pages/settings_page.dart';
import 'package:example/utils/eip155_data.dart';
import 'package:example/widgets/session_request_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wallet_connect/wallet_connect.dart';
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
  final _pageController = PageController();
  int _activePage = 0;
  SignClient? _signClient;
  late bool initializing;
  final _web3client = Web3Client('', http.Client());

  @override
  void initState() {
    _pageController.addListener(() {
      setState(() {
        _activePage = _pageController.page?.toInt() ?? 0;
      });
    });
    _initialize();
    super.initState();
  }

  void _initialize() async {
    initializing = true;
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
    );

    _signClient!.on(SignClientEvent.SESSION_PROPOSAL.value, (data) async {
      final eventData = data as SignClientEventParams<RequestSessionPropose>;
      log('SESSION_PROPOSAL: $eventData');

      _onSessionRequest(eventData.id!, eventData.params!);
    });

    _signClient!.on(SignClientEvent.SESSION_REQUEST.value, (data) async {
      final eventData = data as SignClientEventParams<RequestSessionRequest>;
      log('SESSION_REQUEST: $eventData');
      final session = _signClient!.session.get(eventData.topic!);

      switch (eventData.params!.request.method.toEip155Method()) {
        case Eip155Methods.PERSONAL_SIGN:
          final requestParams =
              eventData.params!.request.params as List<String>;
          final message = WCEthereumSignMessage(
            raw: requestParams,
            type: WCSignType.PERSONAL_MESSAGE,
          );
          return _onSign(eventData.id!, eventData.topic!, session, message);
        case Eip155Methods.ETH_SIGN:
          // TODO: Handle this case.
          break;
        case Eip155Methods.ETH_SIGN_TYPED_DATA:
          // TODO: Handle this case.
          break;
        case Eip155Methods.ETH_SIGN_TYPED_DATA_V3:
          // TODO: Handle this case.
          break;
        case Eip155Methods.ETH_SIGN_TYPED_DATA_V4:
          // TODO: Handle this case.
          break;
        case Eip155Methods.ETH_SIGN_TRANSACTION:
          // TODO: Handle this case.
          break;
        case Eip155Methods.ETH_SEND_TRANSACTION:
          // TODO: Handle this case.
          break;
        case Eip155Methods.ETH_SEND_RAW_TRANSACTION:
          // TODO: Handle this case.
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
    });

    setState(() {
      initializing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      extendBodyBehindAppBar: true,
      body: initializing
          ? const Padding(
              padding: EdgeInsets.only(top: kToolbarHeight),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : PageView(
              controller: _pageController,
              children: [
                const AccountsPage(),
                SessionsPage(signClient: _signClient!),
                ConnectPage(signClient: _signClient!),
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
              curve: Curves.easeInBack,
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
                  curve: Curves.easeInBack,
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
                  curve: Curves.easeInBack,
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
                  curve: Curves.easeInBack,
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
                  curve: Curves.easeInBack,
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

  _connectToPreviousSession() {
    // final _sessionSaved = _prefs.getString('session');
    // debugPrint('_sessionSaved $_sessionSaved');
    // _sessionStore = _sessionSaved != null
    //     ? WCSessionStore.fromJson(jsonDecode(_sessionSaved))
    //     : null;
    // if (_sessionStore != null) {
    //   debugPrint('_sessionStore $_sessionStore');
    //   widget.signClient.connectFromSessionStore(_sessionStore!);
    // } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('No previous session found.'),
    ));
    // }
  }

  _onSwitchNetwork(int id, int chainId) async {
    // await widget.signClient.updateSession(chainId: chainId);
    // widget.signClient.approveRequest<Null>(id: id, result: null);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Changed network to $chainId.'),
    ));
  }

  _onSessionRequest(int id, RequestSessionPropose proposal) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: SessionRequestView(
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

  _onSessionError(dynamic message) {
    showDialog(
      context: context,
      builder: (_) {
        return SimpleDialog(
          title: Text("Error"),
          contentPadding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('Some Error Occured. $message'),
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
                  child: Text('CLOSE'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  _onSessionClosed(int? code, String? reason) {
    showDialog(
      context: context,
      builder: (_) {
        return SimpleDialog(
          title: Text("Session Ended"),
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
                  child: Text('CLOSE'),
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
    // TBD
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
