import 'package:flutter/foundation.dart';

class AccountDetails {
  final String address;
  final String chain;

  const AccountDetails({required this.address, required this.chain});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AccountDetails &&
        other.address == address &&
        other.chain == chain;
  }

  @override
  int get hashCode => address.hashCode ^ chain.hashCode;
}

class Account {
  final String name;
  final String mnemonic;
  final String privateKey;
  final List<AccountDetails> details;

  const Account({
    required this.name,
    required this.mnemonic,
    required this.privateKey,
    required this.details,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Account &&
        other.name == name &&
        other.mnemonic == mnemonic &&
        other.privateKey == privateKey &&
        listEquals(other.details, details);
  }

  @override
  int get hashCode {
    return name.hashCode ^
        mnemonic.hashCode ^
        privateKey.hashCode ^
        details.hashCode;
  }

  Account copyWith({
    String? name,
    String? mnemonic,
    String? privateKey,
    List<AccountDetails>? details,
  }) {
    return Account(
      name: name ?? this.name,
      mnemonic: mnemonic ?? this.mnemonic,
      privateKey: privateKey ?? this.privateKey,
      details: details ?? this.details,
    );
  }
}
