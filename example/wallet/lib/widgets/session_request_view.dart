import 'dart:developer';

import 'package:example_wallet/models/accounts.dart';
import 'package:example_wallet/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:wallet_connect/wallet_connect.dart';

class SessionRequestView extends StatefulWidget {
  final List<Account> accounts;
  final RequestSessionPropose proposal;
  final void Function(SessionNamespaces) onApprove;
  final void Function() onReject;

  const SessionRequestView({
    Key? key,
    required this.accounts,
    required this.proposal,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  @override
  State<SessionRequestView> createState() => _SessionRequestViewState();
}

class _SessionRequestViewState extends State<SessionRequestView> {
  late AppMetadata _metadata;
  late List<String> _selectedAccountIds;

  @override
  void initState() {
    _metadata = widget.proposal.proposer.metadata;
    _selectedAccountIds = [];
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
                final item =
                    widget.proposal.requiredNamespaces.entries.elementAt(idx);
                return NamespaceView(
                  type: item.key,
                  accounts: widget.accounts,
                  namespace: item.value,
                  selectedAccountIds: _selectedAccountIds,
                );
              },
              separatorBuilder: (_, __) =>
                  const Divider(height: 1.5, thickness: 1.5),
              itemCount: widget.proposal.requiredNamespaces.entries.length,
            ),
          ),
          const Divider(height: 1.5, thickness: 1.5),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40.0,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                      onPressed: () {
                        final SessionNamespaces params = {};
                        for (final entry
                            in widget.proposal.requiredNamespaces.entries) {
                          final List<String> accounts = [];
                          for (final idStr in _selectedAccountIds) {
                            final accs = widget.accounts.where((element) =>
                                '${entry.key}:${element.id}' == idStr);
                            if (accs.isNotEmpty) {
                              for (final chain in entry.value.chains.where(
                                  (c) => accs.first.details
                                      .any((ad) => ad.chain == c))) {
                                accounts.add(
                                    '$chain:${accs.first.details.firstWhere((e) => e.chain == chain).address}');
                              }
                            }
                          }
                          params[entry.key] = SessionNamespace(
                            accounts: accounts,
                            methods: entry.value.methods,
                            events: entry.value.events,
                          );
                          log('SESSION: ${params[entry.key]!.toJson()}');
                        }
                        widget.onApprove(params);
                      },
                      child: const Text('Approve'),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: SizedBox(
                    height: 40.0,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.red.shade300,
                      ),
                      onPressed: widget.onReject,
                      child: const Text('Reject'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NamespaceView extends StatefulWidget {
  final String type;
  final List<Account> accounts;
  final ProposalRequiredNamespace namespace;
  final List<String> selectedAccountIds;

  const NamespaceView({
    super.key,
    required this.type,
    required this.accounts,
    required this.namespace,
    required this.selectedAccountIds,
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
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review ${widget.type} permissions',
            style: const TextStyle(fontSize: 17.0),
          ),
          const SizedBox(height: 8.0),
          ...widget.namespace.chains
              .map((chain) => Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border:
                          Border.all(color: Colors.grey.shade300, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getChainName(chain),
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16.0),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                          child: Text(
                            'Methods',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          widget.namespace.methods.isEmpty
                              ? '-'
                              : widget.namespace.methods.join(', '),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                          child: Text(
                            'Events',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          widget.namespace.events.isEmpty
                              ? '-'
                              : widget.namespace.events.join(', '),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Choose ${widget.type} accounts',
              style: const TextStyle(fontSize: 17.0),
            ),
          ),
          ...widget.accounts
              .where((acc) => acc.details.any(
                  (accDetails) => accDetails.chain.startsWith(widget.type)))
              .map((acc) {
            final details =
                acc.details.firstWhere((e) => e.chain.startsWith(widget.type));
            final isSelected =
                widget.selectedAccountIds.contains('${widget.type}:${acc.id}');

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (val) {
                      if (isSelected) {
                        widget.selectedAccountIds
                            .remove('${widget.type}:${acc.id}');
                      } else {
                        widget.selectedAccountIds
                            .add('${widget.type}:${acc.id}');
                      }
                      setState(() {});
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                  Text(
                      '${acc.name} - ${details.address.substring(0, 6)}...${details.address.substring(details.address.length - 6)}'),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
