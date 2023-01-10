import 'package:flutter/material.dart';
import 'package:wallet_connect/core/models/app_metadata.dart';
import 'package:wallet_connect/sign/engine/types.dart';
import 'package:wallet_connect/sign/sign-client/client/client.dart';
import 'package:wallet_connect/sign/sign-client/client/types.dart';
import 'package:wallet_connect/sign/sign-client/proposal/types.dart';
import 'package:wallet_connect/sign/sign-client/session/types.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet Demo',
      home: const ExampleApp(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  late final SignClient signClient;

  init() async {
    try {
      signClient = await SignClient.init(
        projectId: "73801621aec60dfaa2197c7640c15858",
        relayUrl: "wss://relay.walletconnect.com",
        metadata: AppMetadata(
          name: 'Wallet',
          description: 'Wallet for WalletConnect',
          url: 'https://walletconnect.com/',
          icons: ['https://avatars.githubusercontent.com/u/37784886'],
        ),
      );

      signClient.on(SignClientTypesEvent.SESSION_PROPOSAL.value, (event) async {
        print('HALLA SESSION_PROPOSAL ${event.eventData}');
        await Future.delayed(const Duration(seconds: 3));
        final eventData = (event.eventData as Map<String, dynamic>);
        final id = eventData['id'] as int;
        final params = ProposalTypesStruct.fromJson(
            eventData['params'] as Map<String, dynamic>);

        final data = await signClient.approve(SessionApproveParams(
          id: id,
          namespaces: {
            'eip155': SessionTypesNamespace(
              accounts: ["eip155:1:0x2Ee331840018465bD7Fe74aA4E442b9EA407fBBE"],
              methods: [
                "personal_sign",
                "eth_sendTransaction",
                "eth_signTransaction",
                "eth_sign",
                "eth_signTypedData"
              ],
              events: ["chainChanged", "accountsChanged"],
              // extension: [
              //   SessionTypesNamespace(
              //     accounts: ["eip:137"],
              //     methods: ["eth_sign"],
              //     events: [],
              //   ),
              // ],
            ),
          },
        ));
        print('HALLA APPROVE ${data.topic} ${data.acknowledged}');
      });
      signClient.on(SignClientTypesEvent.SESSION_PING.value, (event) {
        print('HALLA SESSION_PING ${event.eventData}');
      });
      signClient.on(SignClientTypesEvent.SESSION_REQUEST.value, (event) {
        print('HALLA SESSION_REQUEST ${event.eventData}');
      });
      signClient.on(SignClientTypesEvent.SESSION_EVENT.value, (event) {
        print('HALLA SESSION_EVENT ${event.eventData}');
      });

      await signClient.pair(
          'wc:22153f76e25f3018558e7a5d7727ecb9d5807b0fca6e63aeef094bff8b44deaa@2?relay-protocol=irn&symKey=1a968a5b11cf091cce258710ee2c4291e71a6963b318b12a8b43005f065151a3');
    } catch (e) {}
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet Connect'),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {},
          child: Text('START'),
        ),
      ),
    );
  }
}
