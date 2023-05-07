import 'dart:typed_data';

import 'package:convert/convert.dart' as convert;
import 'dart:convert' as convert_dart;

abstract class SymmetricCrypto {
  /// 加密
  Uint8List encrypt(Uint8List data);

  /// 解密
  Uint8List decrypt(Uint8List data);

  /// 加密并使用十六进制输出
  String encryptHex(Uint8List data) {
    return convert.hex.encode(encrypt(data).toList());
    // return HexUtil.encodeHex(encrypt(data));
  }

  /// utf8编码后加密
  Uint8List encryptStr(String data) {
    return encrypt(Uint8List.fromList(convert_dart.utf8.encode(data)));
    // return encrypt(StrUtil.encodeUtf8(data));
  }

  /// 加密并使用十六进制输出
  String encryptStrHex(String data) {
    return convert.hex.encode(encryptStr(data).toList());
  }

  /// 解密并使用十六进制输出
  String decryptHex(Uint8List data) {
    return convert.hex.encode(decrypt(data).toList());
  }

  /// 解密并使用utf8解码输出
  String decryptStr(Uint8List data) {
    return convert_dart.utf8.decode(decrypt(data).toList());
    // return StrUtil.decode(decrypt(data));
  }
}
