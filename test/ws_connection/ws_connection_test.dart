import 'package:test/test.dart';
import 'package:wallet_connect/utils/crypto.dart' as crypto;
import 'package:wallet_connect/utils/misc.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/ws-connection/ws.dart';
import 'package:wallet_connect/wc_utils/relay_auth/api.dart';

import 'mock_data.dart';

void main() {
  group('WS Connection', () {
    late String url;
    setUp(() async {
      final keyPair = await generateKeyPair();
      final sub = crypto.generateRandomBytes32();
      final ttl = 5000;
      final jwt = await signJWT(
        sub: sub,
        aud: RELAY_URL,
        ttl: ttl,
        keyPair: keyPair,
      );
      url = formatRelayRpcUrl(
        protocol: "wc",
        version: 2,
        sdkVersion: '2.1.5',
        relayUrl: RELAY_URL,
        projectId: "3cbaa32f8fbf3cdcc87d27ca1fa68069",
        auth: jwt,
      );
    });
    test('conn', () async {
      final conn = WsConnection(url);
      expect(conn.connected, false);
      await conn.open();
      expect(conn.connected, true);
    });
  });
}
