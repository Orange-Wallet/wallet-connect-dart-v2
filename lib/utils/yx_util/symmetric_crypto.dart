import 'dart:typed_data';

import 'package:convert/convert.dart' as convert;
import 'dart:convert' as convert_dart;

abstract class SymmetricCrypto {
  Uint8List encrypt(List<int> data_list);

  Uint8List decrypt(List<int> data_list);

  String encryptHex(Uint8List data) {
    return convert.hex.encode(encrypt(data).toList());
  }

  Uint8List encryptStr(String data) {
    return encrypt(Uint8List.fromList(convert_dart.utf8.encode(data)));
  }

  String encryptStrHex(String data) {
    return convert.hex.encode(encryptStr(data).toList());
  }

  String decryptHex(Uint8List data) {
    return convert.hex.encode(decrypt(data).toList());
  }

  String decryptStr(Uint8List data) {
    return convert_dart.utf8.decode(decrypt(data).toList());
  }
}
