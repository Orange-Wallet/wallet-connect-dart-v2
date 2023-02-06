import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:test/test.dart';
import 'package:walletconnect_v2/core/crypto/models.dart';
import 'package:walletconnect_v2/utils/crypto.dart';
import 'package:walletconnect_v2/wc_utils/jsonrpc/models/models.dart';

import 'mock_data.dart';

final TEST_MESSAGE = jsonEncode(JsonRpcRequest(
  id: 1,
  jsonrpc: "2.0",
  method: "test_method",
  params: {},
).toJson());

const TEST_SELF = TEST_KEY_PAIRS_A;
const TEST_PEER = TEST_KEY_PAIRS_B;

const TEST_IV = "717765636661617364616473";

const TEST_SEALED =
    "7a5a1e843debf98b01d6a75718b5ee27115eafa3caba9703ca1c5601a6af2419045320faec2073cc8b6b8dc439e63e21612ff3883c867e0bdcd72c833eb7f7bb2034a9ec35c2fb03d93732";

const TEST_ENCODED_TYPE_0 =
    "AHF3ZWNmYWFzZGFkc3paHoQ96/mLAdanVxi17icRXq+jyrqXA8ocVgGmryQZBFMg+uwgc8yLa43EOeY+IWEv84g8hn4L3Ncsgz6397sgNKnsNcL7A9k3Mg==";
const TEST_ENCODED_TYPE_1 =
    "Af96fVdnw2KwoXrZIpnr23gx3L2aVpWcATaMdARUOzNCcXdlY2ZhYXNkYWRzeloehD3r+YsB1qdXGLXuJxFer6PKupcDyhxWAaavJBkEUyD67CBzzItrjcQ55j4hYS/ziDyGfgvc1yyDPrf3uyA0qew1wvsD2Tcy";

const TEST_HASHED_MESSAGE =
    "15112289b5b794e68d1ea3cd91330db55582a37d0596f7b99ea8becdf9d10496";

void main() async {
  group("Crypto", () {
    test("deriveSymKey", () async {
      final symKeyA =
          await deriveSymKey(TEST_SELF.privateKey, TEST_PEER.publicKey);
      expect(symKeyA, TEST_SYM_KEY);
      final symKeyB =
          await deriveSymKey(TEST_PEER.privateKey, TEST_SELF.publicKey);
      expect(symKeyB, TEST_SYM_KEY);
    });
    test("hashKey", () async {
      final hashedKey = await hashKey(TEST_SHARED_KEY);
      expect(hashedKey, TEST_HASHED_KEY);
    });
    test("hashMessage", () async {
      final hashedMessage = await hashMessage(TEST_MESSAGE);
      expect(hashedMessage, TEST_HASHED_MESSAGE);
    });
    test("encrypt (type 0)", () async {
      final encoded = await encrypt(
        symKey: TEST_SYM_KEY,
        message: TEST_MESSAGE,
        iv: TEST_IV,
      );
      expect(encoded, TEST_ENCODED_TYPE_0);
      final deserialized = deserialize(encoded);
      final iv = hex.encode(deserialized.iv);
      expect(iv, TEST_IV);
      final sealed = hex.encode(deserialized.sealed);
      expect(sealed, TEST_SEALED);
    });
    test("decrypt (type 0)", () async {
      final decrypted = await decrypt(
        symKey: TEST_SYM_KEY,
        encoded: TEST_ENCODED_TYPE_0,
      );
      expect(decrypted, TEST_MESSAGE);
    });
    test("encrypt (type 1)", () async {
      final encoded = await encrypt(
        type: 1,
        symKey: TEST_SYM_KEY,
        senderPublicKey: TEST_SELF.publicKey,
        message: TEST_MESSAGE,
        iv: TEST_IV,
      );
      expect(encoded, TEST_ENCODED_TYPE_1);
      final deserialized = deserialize(encoded);
      final iv = hex.encode(deserialized.iv);
      expect(iv, TEST_IV);
      final sealed = hex.encode(deserialized.sealed);
      expect(sealed, TEST_SEALED);
    });
    test("decrypt (type 1)", () async {
      final encoded = TEST_ENCODED_TYPE_1;
      final params = validateDecoding(
        encoded: encoded,
        opts: CryptoDecodeOptions(
          receiverPublicKey: TEST_PEER.publicKey,
        ),
      );
      expect(isTypeOneEnvelope(params), true);
      if (!isTypeOneEnvelope(params)) return;
      expect(params.type, 1);
      expect(params.senderPublicKey, TEST_SELF.publicKey);
      expect(params.receiverPublicKey, TEST_PEER.publicKey);
      final symKey =
          await deriveSymKey(TEST_PEER.privateKey, params.senderPublicKey!);
      expect(symKey, TEST_SYM_KEY);
      final decrypted = await decrypt(symKey: symKey, encoded: encoded);
      expect(decrypted, TEST_MESSAGE);
    });
  });
}
