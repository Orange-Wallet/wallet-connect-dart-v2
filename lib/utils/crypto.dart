import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

String hashMessage(String message) {
  final result = sha256.convert(utf8.encode(message)).bytes;
  return hex.encode(result);
}
