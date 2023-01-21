import 'package:example/utils/constants.dart';
import 'package:example/utils/helpers.dart';
import 'package:example/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedAccount = Constants.accounts.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomAppBar(title: 'Accounts'),
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
