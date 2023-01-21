import 'package:example/pages/accounts_page.dart';
import 'package:example/pages/connect_page.dart';
import 'package:example/pages/pairings_page.dart';
import 'package:example/pages/sessions_page.dart';
import 'package:example/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:wallet_connect/core/models/app_metadata.dart';
import 'package:wallet_connect/sign/sign-client/client/sign_client.dart';

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
