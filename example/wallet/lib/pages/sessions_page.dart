import 'package:example_wallet/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:walletconnect_v2/sign/sign-client/client/sign_client.dart';

class SessionsPage extends StatefulWidget {
  final SignClient signClient;

  const SessionsPage({
    super.key,
    required this.signClient,
  });

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  @override
  Widget build(BuildContext context) {
    final sessions = widget.signClient.session.getAll();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomAppBar(title: 'Sessions'),
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
                  separatorBuilder: (_, __) => const SizedBox(height: 8.0),
                  itemCount: sessions.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 16.0,
                  ),
                ),
        ),
      ],
    );
  }
}
