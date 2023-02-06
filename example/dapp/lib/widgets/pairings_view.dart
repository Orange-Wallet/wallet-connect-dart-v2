import 'package:example_dapp/main.dart';
import 'package:example_dapp/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:walletconnect_v2/walletconnect_v2.dart';

class PairingsView extends StatelessWidget {
  final List<PairingStruct> pairings;

  const PairingsView({
    super.key,
    required this.pairings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomAppBar(title: 'Pairings'),
        const Divider(height: 1.0),
        Flexible(
          child: pairings.isEmpty
              ? const Center(child: Text('No pairings found.'))
              : ListView.separated(
                  itemBuilder: (_, idx) {
                    return ListTile(
                      onTap: () {
                        Navigator.pop(context, pairings[idx].topic);
                      },
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
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 8.0),
                  shrinkWrap: true,
                  itemCount: pairings.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 16.0,
                  ),
                ),
        ),
        Center(
          child: Container(
            height: 50.0,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 16.0,
            ),
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(colors: [primaryColor, secondaryColor]),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context, '');
              },
              style: TextButton.styleFrom(
                primary: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.w500),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('New Pairing'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
