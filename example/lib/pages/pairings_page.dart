import 'package:example/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:wallet_connect_v2/wallet_connect.dart';

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomAppBar(title: 'Pairings'),
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
                      trailing: IconButton(
                        onPressed: () {
                          signClient.pairing
                              .delete(
                            pairings[idx].topic,
                            getSdkError(SdkErrorKey.USER_DISCONNECTED),
                          )
                              .then((_) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('Pairing delete successfully.'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(milliseconds: 500),
                            ));
                          }).catchError((_) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('Failed to delete pairing.'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(milliseconds: 500),
                            ));
                          });
                        },
                        icon: Icon(
                          Icons.delete_outline_outlined,
                          color: Colors.red.shade300,
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 8.0),
                  itemCount: pairings.length,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 16.0),
                ),
        ),
      ],
    );
  }
}
