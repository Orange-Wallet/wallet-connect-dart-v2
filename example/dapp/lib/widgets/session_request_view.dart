import 'package:example_dapp/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:wallet_connect/wallet_connect.dart';

class SessionRequestView extends StatefulWidget {
  final SessionStruct session;

  const SessionRequestView({
    Key? key,
    required this.session,
  }) : super(key: key);

  @override
  State<SessionRequestView> createState() => _SessionRequestViewState();
}

class _SessionRequestViewState extends State<SessionRequestView> {
  late AppMetadata _metadata;
  late List<String> _selectedAccountIds;

  @override
  void initState() {
    _metadata = widget.session.peer.metadata;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              children: [
                Container(
                  height: 50.0,
                  width: 50.0,
                  padding: const EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade300,
                    image: _metadata.icons.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(_metadata.icons.first))
                        : null,
                  ),
                  child: _metadata.icons.isNotEmpty
                      ? null
                      : Center(
                          child: Text(
                            _metadata.name.substring(0, 1),
                            style: const TextStyle(
                              fontSize: 24.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _metadata.name,
                        style: const TextStyle(fontSize: 16.0),
                        maxLines: 1,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          _metadata.url,
                          style: const TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.normal,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1.5, thickness: 1.5),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemBuilder: (_, idx) {
                final item = widget.session.namespaces.entries.elementAt(idx);
                return NamespaceView(
                  type: item.key,
                  namespace: item.value,
                );
              },
              separatorBuilder: (_, __) =>
                  const Divider(height: 1.5, thickness: 1.5),
              itemCount: widget.session.namespaces.entries.length,
            ),
          ),
          // const Divider(height: 1.5, thickness: 1.5),
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: SizedBox(
          //           height: 40.0,
          //           child: TextButton(
          //             style: TextButton.styleFrom(
          //               primary: Colors.white,
          //               backgroundColor:
          //                   Theme.of(context).colorScheme.secondary,
          //             ),
          //             onPressed: () {
          //               final SessionNamespaces params = {};
          //               for (final entry
          //                   in widget.proposal.requiredNamespaces.entries) {
          //                 final List<String> accounts = [];
          //                 for (final idStr in _selectedAccountIds) {
          //                   final accs = widget.accounts.where((element) =>
          //                       '${entry.key}:${element.id}' == idStr);
          //                   if (accs.isNotEmpty) {
          //                     for (final chain in entry.value.chains.where(
          //                         (c) => accs.first.details
          //                             .any((ad) => ad.chain == c))) {
          //                       accounts.add(
          //                           '$chain:${accs.first.details.firstWhere((e) => e.chain == chain).address}');
          //                     }
          //                   }
          //                 }
          //                 params[entry.key] = SessionNamespace(
          //                   accounts: accounts,
          //                   methods: entry.value.methods,
          //                   events: entry.value.events,
          //                 );
          //                 log('SESSION: ${params[entry.key]!.toJson()}');
          //               }
          //               widget.onApprove(params);
          //             },
          //             child: const Text('Approve'),
          //           ),
          //         ),
          //       ),
          //       const SizedBox(width: 16.0),
          //       Expanded(
          //         child: SizedBox(
          //           height: 40.0,
          //           child: TextButton(
          //             style: TextButton.styleFrom(
          //               primary: Colors.white,
          //               backgroundColor: Colors.red.shade300,
          //             ),
          //             onPressed: widget.onReject,
          //             child: const Text('Reject'),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

class NamespaceView extends StatefulWidget {
  final String type;
  final SessionNamespace namespace;

  const NamespaceView({
    super.key,
    required this.type,
    required this.namespace,
  });

  @override
  State<NamespaceView> createState() => _NamespaceViewState();
}

class _NamespaceViewState extends State<NamespaceView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (_, idx) {
        final formattedAccStr = widget.namespace.accounts[idx];
        final chainId =
            '${formattedAccStr.split(':')[0]}:${formattedAccStr.split(':')[1]}';
        final accAddress = formattedAccStr.split(':')[2];

        return Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getChainName(chainId),
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 16.0),
              ),
              Text(
                accAddress,
                style: const TextStyle(fontSize: 16.0),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                child: Text(
                  'Methods',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              ...widget.namespace.methods
                  .map((e) => TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(e),
                        ),
                      ))
                  .toList(),
            ],
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 8.0),
      itemCount: widget.namespace.accounts.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }
}
