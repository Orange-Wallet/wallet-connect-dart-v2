import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:web3dart/crypto.dart';

class HDKeyUtils {
  static String getPrivateKey(
    String mnemonic, {
    int? route,
  }) {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(seed);
    final child = root.derivePath("m/44'/60'/0'/0/${route ?? 0}");
    final privateKey = bytesToHex(child.privateKey!.toList());
    return privateKey;
  }
}
