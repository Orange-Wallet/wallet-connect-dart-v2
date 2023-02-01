import 'package:example_dapp/main.dart';
import 'package:example_dapp/models/chain_metadata.dart';
import 'package:example_dapp/utils/helpers.dart';
import 'package:flutter/material.dart';

class NetworksView extends StatefulWidget {
  final List<ChainMetadata> chains;
  final List<ChainMetadata> selectedChains;
  final VoidCallback onConnect;

  const NetworksView({
    super.key,
    required this.chains,
    required this.selectedChains,
    required this.onConnect,
  });

  @override
  State<NetworksView> createState() => _NetworksViewState();
}

class _NetworksViewState extends State<NetworksView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Select chains:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: ListView.separated(
            itemBuilder: (_, idx) {
              final selectedIdx = widget.selectedChains
                  .indexWhere((element) => element == widget.chains[idx]);
              final isSelected = selectedIdx >= 0;

              return ListTile(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      widget.selectedChains.removeAt(selectedIdx);
                    } else {
                      widget.selectedChains.add(widget.chains[idx]);
                    }
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(
                    color: isSelected
                        ? Colors.grey.shade500
                        : Colors.blueGrey.shade100,
                    width: 2.0,
                  ),
                ),
                tileColor: Colors.blueGrey.shade100,
                title: Text(getChainName(widget.chains[idx].chainId)),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 8.0),
            itemCount: widget.chains.length,
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
              onPressed: widget.onConnect,
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
      ],
    );
  }
}
