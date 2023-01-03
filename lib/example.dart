import 'package:flutter/material.dart';
import 'package:wallet_connect/core/core/types.dart';
import 'package:wallet_connect/sign/sign-client/client/client.dart';
import 'package:wallet_connect/sign/sign-client/client/types.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ExampleApp(),
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

  @override
  void initState() {
    signClient = SignClient(
      projectId: "73801621aec60dfaa2197c7640c15858",
      relayUrl: "wss://relay.walletconnect.com",
      metadata: Metadata(
        name: 'Wallet',
        description: 'Wallet for WalletConnect',
        url: 'https://walletconnect.com/',
        icons: ['https://avatars.githubusercontent.com/u/37784886'],
      ),
    );
    signClient.on(SignClientTypesEvent.SESSION_PROPOSAL.value, (event) {
      print('SESSION_PROPOSAL ${event.eventData}');
    });
    signClient.init();
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
