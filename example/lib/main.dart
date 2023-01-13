import 'dart:developer';

import 'package:example/widgets/session_request_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scan/scan.dart';
import 'package:wallet_connect/core/models/app_metadata.dart';
import 'package:wallet_connect/sign/engine/types.dart';
import 'package:wallet_connect/sign/sign-client/client/client.dart';
import 'package:wallet_connect/sign/sign-client/client/types.dart';
import 'package:wallet_connect/sign/sign-client/proposal/types.dart';
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
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          secondary: secondaryColor,
        ),
      ),
      home: const MyHomePage(title: 'Wallet Connect'),
    );
  }
}

const primaryColor = Color(0xFFbe5bd8);
const secondaryColor = Color(0xFF0070f2);

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late SignClient _signClient;

  late TextEditingController _uriController;

  // final _web3client = Web3Client(rpcUri, http.Client());

  late bool _scanView;

  @override
  void initState() {
    _scanView = false;
    _initialize();
    super.initState();
  }

  _initialize() async {
    _uriController = TextEditingController();
    _signClient = await SignClient.init(
      projectId: "73801621aec60dfaa2197c7640c15858",
      relayUrl: "wss://relay.walletconnect.com",
      metadata: const AppMetadata(
        name: 'Wallet',
        description: 'Wallet for WalletConnect',
        url: 'https://walletconnect.com/',
        icons: ['https://avatars.githubusercontent.com/u/37784886'],
      ),
    );
    _signClient.on(SignClientTypesEvent.SESSION_PROPOSAL.value, (data) async {
      final eventData = (data as Map<String, dynamic>);
      final id = eventData['id'] as int;
      final proposal = ProposalTypesStruct.fromJson(
          eventData['params'] as Map<String, dynamic>);
      log('PROPOSAL ${proposal.toJson()}');
      _onSessionRequest(id, proposal);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: .0,
        title: Text(
          widget.title,
          style: const TextStyle(color: primaryColor),
        ),
      ),
      body: Column(
        children: [
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
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
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
                  borderSide:
                      BorderSide(color: Colors.grey.shade300, width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: secondaryColor, width: 2.5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.grey.shade300, width: 2.0),
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
                      foregroundColor: Colors.white,
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
          child: Icon(
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
          items: [
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

  _qrScanHandler(String value) {
    if (Uri.tryParse(value) != null) {
      _signClient.pair(value);
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
    //   _signClient.connectFromSessionStore(_sessionStore!);
    // } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('No previous session found.'),
    ));
    // }
  }

  _onSwitchNetwork(int id, int chainId) async {
    // await _signClient.updateSession(chainId: chainId);
    // _signClient.approveRequest<Null>(id: id, result: null);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Changed network to $chainId.'),
    ));
  }

  _onSessionRequest(int id, ProposalTypesStruct proposal) {
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
            _signClient.approve(params);
            // await approved.acknowledged;
            Navigator.pop(context);
          },
          onReject: () {
            _signClient.reject(SessionRejectParams(
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
                    foregroundColor: Colors.white,
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
                    foregroundColor: Colors.white,
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
