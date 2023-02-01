import 'package:example_wallet/models/accounts.dart';
import 'package:example_wallet/utils/helpers.dart';
import 'package:example_wallet/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccountsPage extends StatefulWidget {
  final List<Account> accounts;

  const AccountsPage({super.key, required this.accounts});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  late Account selectedAccount;

  @override
  void initState() {
    selectedAccount = widget.accounts.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomAppBar(
          title: 'Accounts',
          padding: EdgeInsets.fromLTRB(
            8.0,
            MediaQuery.of(context).padding.top + 8.0,
            8.0,
            8.0,
          ),
          trailing: [
            Container(
              padding: const EdgeInsets.only(left: 16.0, right: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.grey.shade200,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  elevation: 2,
                  value: selectedAccount.id,
                  borderRadius: BorderRadius.circular(10.0),
                  dropdownColor: Colors.white,
                  selectedItemBuilder: (_) => widget.accounts
                      .map((e) => Center(child: Text(e.name)))
                      .toList(),
                  items: widget.accounts
                      .map((e) => DropdownMenuItem(
                            value: e.id,
                            child: Text(
                              e.name,
                              style: TextStyle(
                                color: e.id == selectedAccount.id
                                    ? Theme.of(context).colorScheme.secondary
                                    : null,
                                fontWeight: e.id == selectedAccount.id
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    setState(() {});
                    selectedAccount = widget.accounts
                        .firstWhere((element) => element.id == v);
                  },
                ),
              ),
            ),
          ],
        ),
        const Divider(height: 1.0),
        Expanded(
          child: selectedAccount.details.isEmpty
              ? const Center(child: Text('No accounts found.'))
              : ListView.separated(
                  itemBuilder: (_, idx) {
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      tileColor: Colors.blueGrey.shade100,
                      title: Text(
                          getChainName(selectedAccount.details[idx].chain)),
                      subtitle: Text(
                        '${selectedAccount.details[idx].address.substring(0, 6)}...${selectedAccount.details[idx].address.substring(selectedAccount.details[idx].address.length - 6)}',
                        style: const TextStyle(color: Colors.blueAccent),
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(
                            text: selectedAccount.details[idx].address,
                          )).then((value) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('Copied address.'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(milliseconds: 500),
                            ));
                          }).catchError((_) {});
                        },
                        icon: const Icon(Icons.paste_rounded),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 8.0),
                  itemCount: selectedAccount.details.length,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 16.0),
                ),
        ),
      ],
    );
  }
}
