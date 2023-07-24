import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'symmetric_crypto.dart';

class AEADChaCha20Poly1305 extends SymmetricCrypto {
  CipherParameters parameters;
  ChaCha20Poly1305? _encrypt;
  ChaCha20Poly1305? _decrypt;

  AEADChaCha20Poly1305.withIV(Uint8List key, Uint8List iv)
      : parameters = ParametersWithIV(KeyParameter(key), iv);

  AEADChaCha20Poly1305.withAEAD(
      Uint8List key, int macSize, Uint8List nonce, Uint8List associatedData)
      : parameters =
            AEADParameters(KeyParameter(key), macSize, nonce, associatedData);

  void _init(bool forEncryption) {
    if (forEncryption) {
      _encrypt ??= ChaCha20Poly1305(ChaCha7539Engine(), Poly1305())
        ..init(forEncryption, parameters);
    } else {
      _decrypt ??= ChaCha20Poly1305(ChaCha7539Engine(), Poly1305())
        ..init(forEncryption, parameters);
    }
  }

  @override
  Uint8List encrypt(Uint8List data) {
    _init(true);
    var encrypt = _encrypt;
    encrypt!.reset();
    var enc = Uint8List(encrypt.getOutputSize(data.length));
    var len = encrypt.processBytes(data, 0, data.length, enc, 0);
    encrypt.doFinal(enc, len);
    encrypt.finishData(State.ENC_INIT);
    return enc;
  }

  @override
  Uint8List decrypt(Uint8List data) {
    _init(false);
    var decrypt = _decrypt;
    decrypt!.reset();
    var enc = Uint8List(decrypt.getOutputSize(data.length));
    var len = decrypt.processBytes(data, 0, data.length, enc, 0);
    decrypt.doFinal(enc, len);
    return enc;
  }
}
