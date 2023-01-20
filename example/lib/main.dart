import 'dart:developer';

import 'package:example/utils/eip155_data.dart';
import 'package:example/widgets/session_request_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scan/scan.dart';
import 'package:wallet_connect/core/models/app_metadata.dart';
import 'package:wallet_connect/sign/engine/models.dart';
import 'package:wallet_connect/sign/sign-client/client/models.dart';
import 'package:wallet_connect/sign/sign-client/client/sign_client.dart';
import 'package:wallet_connect/sign/sign-client/proposal/models.dart';
import 'package:wallet_connect/utils/error.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/format.dart';

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
    setState(() {
      initializing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: const EdgeInsets.only(top: kToolbarHeight),
        child: initializing
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : PageView(
                controller: _pageController,
                children: [
                  ConnectPage(signClient: _signClient!),
                  SessionsPage(signClient: _signClient!),
                  PairingsPage(signClient: _signClient!),
                ],
              ),
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
          onPressed: () {},
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
        elevation: 1.0,
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: .0,
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: Colors.grey,
          selectedItemColor: secondaryColor,
          currentIndex: _activePage,
          onTap: (idx) => _pageController.animateToPage(
            idx,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInBack,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              label: 'Accounts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.device_hub),
              label: 'Sessions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.link),
              label: 'Pairings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class ConnectPage extends StatefulWidget {
  final SignClient signClient;

  const ConnectPage({
    super.key,
    required this.signClient,
  });

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  late TextEditingController _uriController;

  // final _web3client = Web3Client(rpcUri, http.Client());

  late bool _scanView;

  @override
  void initState() {
    _scanView = false;
    _uriController = TextEditingController();
    _initializeListeners();
    super.initState();
  }

  _initializeListeners() async {
    widget.signClient.on(SignClientEvent.SESSION_PROPOSAL.value, (data) async {
      final eventData = (data as Map<String, dynamic>);
      final id = eventData['id'] as int;
      final proposal =
          ProposalStruct.fromJson(eventData['params'] as Map<String, dynamic>);
      _onSessionRequest(id, proposal);
    });
    widget.signClient.on(SignClientEvent.SESSION_REQUEST.value, (data) async {
      final eventData = (data as Map<String, dynamic>);
      log('DATA $eventData');
      final id = eventData['id'] as int;
      final sessionRequest = SessionRequestParams.fromJson(
        eventData['params'] as Map<String, dynamic>,
      );

      if (sessionRequest.request.method == Eip155Methods.PERSONAL_SIGN.value) {
        final requestParams = sessionRequest.request.params as List<String>;
        final dataToSign = requestParams[0];
        final address = requestParams[1];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(.0, 8.0, .0, 16.0),
          child: Text(
            'Wallet Connect',
            style: TextStyle(
              color: primaryColor,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, .0, 20.0, 20.0),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: _scanView
                  ? ScanView(
                      controller: ScanController(),
                      scanAreaScale: 1,
                      scanLineColor: Colors.green.shade400,
                      onCapture: (data) {
                        _qrScanHandler(data);
                      },
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_2_rounded,
                          size: 100.0,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(height: 16.0),
                        Container(
                          height: 42.0,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [primaryColor, secondaryColor]),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _scanView = true;
                              });
                            },
                            style: TextButton.styleFrom(
                              primary: Colors.white,
                              textStyle:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('Scan QR code'),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const Text(
          'or connect with Wallet Connect uri',
          style: TextStyle(color: Colors.grey),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextFormField(
            controller: _uriController,
            onTap: () {
              Clipboard.getData('text/plain').then((value) {
                if (_uriController.text.isEmpty &&
                    value?.text != null &&
                    Uri.tryParse(value!.text!) != null) {
                  _uriController.text = value.text!;
                }
              });
            },
            decoration: InputDecoration(
              focusColor: secondaryColor,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300, width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: secondaryColor, width: 2.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300, width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              hintText: 'Enter uri',
              suffixIcon: Container(
                margin: const EdgeInsets.only(right: 5.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [primaryColor, secondaryColor]),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: TextButton(
                  onPressed: () {
                    _qrScanHandler(_uriController.text);
                  },
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Connect'),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }

  _qrScanHandler(String value) {
    if (Uri.tryParse(value) != null) {
      widget.signClient.pair(value);
    }
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

  _onSessionRequest(int id, ProposalStruct proposal) {
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
            widget.signClient.approve(params);
            // await approved.acknowledged;
            Navigator.pop(context);
          },
          onReject: () {
            widget.signClient.reject(SessionRejectParams(
              id: id,
              reason: formatErrorMessage(
                  error: getSdkError(SdkErrorKey.USER_DISCONNECTED)),
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
}

class SessionsPage extends StatelessWidget {
  final SignClient signClient;

  const SessionsPage({
    super.key,
    required this.signClient,
  });

  @override
  Widget build(BuildContext context) {
    final sessions = signClient.session.getAll();
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(.0, 8.0, .0, 16.0),
          child: Text(
            'Sessions',
            style: TextStyle(
              color: primaryColor,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Divider(height: 1.0),
        Expanded(
          child: sessions.isEmpty
              ? const Center(child: Text('No sessions found.'))
              : ListView.separated(
                  itemBuilder: (_, idx) {
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      tileColor: Colors.blueGrey.shade100,
                      title: Text(sessions[idx].peer.metadata.name),
                      subtitle: Text(
                        sessions[idx].peer.metadata.url,
                        style: const TextStyle(color: Colors.blueAccent),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(),
                  itemCount: sessions.length,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 16.0),
                ),
        ),
      ],
    );
  }
}

class PairingsPage extends StatelessWidget {
  final SignClient signClient;

  const PairingsPage({
    super.key,
    required this.signClient,
  });

  @override
  Widget build(BuildContext context) {
    final pairings = signClient.pairing.values;
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(.0, 8.0, .0, 16.0),
          child: Text(
            'Pairings',
            style: TextStyle(
              color: primaryColor,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Divider(height: 1.0),
        Expanded(
          child: pairings.isEmpty
              ? const Center(child: Text('No pairings found.'))
              : ListView.separated(
                  itemBuilder: (_, idx) {
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      tileColor: Colors.blueGrey.shade100,
                      title:
                          Text(pairings[idx].peerMetadata?.name ?? 'Unnamed'),
                      subtitle: Text(
                        pairings[idx].peerMetadata?.url ?? '',
                        style: const TextStyle(color: Colors.blueAccent),
                      ),
                      trailing: Icon(Icons.delete_outline_outlined),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(),
                  itemCount: pairings.length,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 16.0),
                ),
        ),
      ],
    );
  }
}
