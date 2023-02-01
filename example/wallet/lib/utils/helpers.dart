import 'package:example_wallet/utils/eip155_data.dart';
import 'package:example_wallet/utils/solana_data.dart';
import 'package:flutter/material.dart';

String getChainName(String value) {
  try {
    if (value.startsWith('eip155')) {
      return Eip155Data.chains[value]!.name;
    } else if (value.startsWith('solana')) {
      return SolanaData.chains[value]!.name;
    }
  } catch (e) {
    debugPrint('Invalid chain');
  }
  return 'Unknown';
}
