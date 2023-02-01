import 'dart:developer';

import 'package:example_dapp/models/chain_metadata.dart';
import 'package:example_dapp/utils/eip155_data.dart';
import 'package:example_dapp/utils/helpers.dart';
import 'package:example_dapp/utils/solana_data.dart';
import 'package:example_dapp/widgets/custom_app_bar.dart';
import 'package:example_dapp/widgets/networks_view.dart';
import 'package:example_dapp/widgets/session_request_view.dart';
import 'package:example_dapp/widgets/uri_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wallet_connect/wallet_connect.dart';
import 'package:wallet_connect/wc_utils/misc/logger/logger.dart';
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
  late bool _initializing;

  SessionStruct? _activeSession;

  late List<ChainMetadata> _chains;

  late List<ChainMetadata> _selectedChains;

  final _web3client = Web3Client('', http.Client());

  SignClient? _signClient;

  List<PairingStruct> _pairings = [];

  @override
  void initState() {
    _chains = [...Eip155Data.mainChains, ...SolanaData.mainChains];
    _selectedChains = [];
    _initialize();
    super.initState();
  }

  void _initialize() async {
    _initializing = true;
    _signClient = await SignClient.init(
      projectId: "73801621aec60dfaa2197c7640c15858",
      relayUrl: "wss://relay.walletconnect.com",
      metadata: const AppMetadata(
        name: "Example Dapp",
        description: "Example Dapp",
        url: 'https://walletconnect.com/',
        icons: ["https://walletconnect.com/walletconnect-logo.png"],
      ),
      database: 'dapp.db',
      logger: Logger(),
    );

    _getPairings();

    _getSessions();

    _signClient!.on(SignClientEvent.SESSION_EVENT.value, (data) async {
      final eventData = data as SignClientEventParams<RequestSessionEvent>;
      log('SESSION_EVENT: $eventData');
    });

    _signClient!.on(SignClientEvent.SESSION_UPDATE.value, (data) async {
      final eventData = data as SignClientEventParams<void>;
      log('SESSION_UPDATE: $eventData');
    });

    _signClient!.on(SignClientEvent.SESSION_DELETE.value, (data) async {
      final eventData = data as SignClientEventParams<void>;
      log('SESSION_DELETE: $eventData');
      // _onSessionClosed(9999, 'Ended.');
    });

    setState(() {
      _initializing = false;
    });
  }

  _getPairings() {
    final allPairings = _signClient!.core.pairing.getPairings();
    _pairings = allPairings.where((e) => e.active).toList();
    log('Pairings: ${_pairings.map((e) => e.toJson())}');
  }

  _getSessions() {
    final sessions = _signClient!.session.getAll();
    _activeSession = sessions.isNotEmpty ? sessions.first : null;
    log('Sessions: ${sessions.map((e) => e.toJson())}');
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
          : Column(
              children: [
                const CustomAppBar(
                  title: 'Wallet Connect Dapp',
                  alignment: Alignment.center,
                  textAlign: TextAlign.center,
                ),
                Expanded(
                  child: _activeSession == null
                      ? NetworksView(
                          chains: _chains,
                          selectedChains: _selectedChains,
                          onConnect: () {
                            final ProposalRequiredNamespaces
                                requiredNamespaces = {};

                            for (final chain in _selectedChains) {
                              final namespaceKey =
                                  chain.chainId.split(':').first;
                              if (requiredNamespaces
                                  .containsKey(namespaceKey)) {
                                requiredNamespaces[namespaceKey]!
                                    .chains
                                    .add(chain.chainId);
                              } else {
                                requiredNamespaces[namespaceKey] =
                                    ProposalRequiredNamespace(
                                  chains: [chain.chainId],
                                  methods: getChainMethods(chain.chainId),
                                  events: getChainEvents(chain.chainId),
                                );
                              }
                            }

                            _signClient!
                                .connect(SessionConnectParams(
                              requiredNamespaces: requiredNamespaces,
                            ))
                                .then((connection) {
                              connection.approval?.then((value) {
                                _activeSession = value;
                                _getSessions();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('Session approval successful.'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(milliseconds: 500),
                                ));
                              }).catchError((_) {
                                _activeSession = null;
                                _getSessions();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('Session approval failed.'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(milliseconds: 500),
                                ));
                              });
                              _onConnection(connection.uri!);
                            });
                          },
                        )
                      : SessionRequestView(session: _activeSession!),
                ),
              ],
            ),
    );
  }

  _onConnection(String uri) {
    showDialog(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(56.0),
          child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: UriView(
              signClient: _signClient!,
              connectionUri: uri,
            ),
          ),
        );
      },
    );
  }
}
