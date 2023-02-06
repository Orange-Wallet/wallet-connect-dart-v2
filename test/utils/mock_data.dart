import 'package:walletconnect_v2/core/crypto/models.dart';
import 'package:walletconnect_v2/core/models/app_metadata.dart';
import 'package:walletconnect_v2/core/relayer/models.dart';
import 'package:walletconnect_v2/sign/sign-client/proposal/models.dart';
import 'package:walletconnect_v2/sign/sign-client/session/models.dart';

const TEST_PAIRING_TOPIC =
    "c9e6d30fb34afe70a15c14e9337ba8e4d5a35dd695c39b94884b0ee60c69d168";

const TEST_SESSION_TOPIC =
    "f5d3f03946b6a2a3b22661fae1385cd1639bfb6f6c070115699b0a2ec1decd8c";

const TEST_KEY_PAIRS_A = CryptoKeyPair(
  privateKey:
      "1fb63fca5c6ac731246f2f069d3bc2454345d5208254aa8ea7bffc6d110c8862",
  publicKey: "ff7a7d5767c362b0a17ad92299ebdb7831dcbd9a56959c01368c7404543b3342",
);
const TEST_KEY_PAIRS_B = CryptoKeyPair(
  privateKey:
      "36bf507903537de91f5e573666eaa69b1fa313974f23b2b59645f20fea505854",
  publicKey: "590c2c627be7af08597091ff80dd41f7fa28acd10ef7191d7e830e116d3a186a",
);

const TEST_SHARED_KEY =
    "9c87e48e69b33a613907515bcd5b1b4cc10bbaf15167b19804b00f0a9217e607";
const TEST_HASHED_KEY =
    "a492906ccc809a411bb53a84572b57329375378c6ad7566f3e1c688200123e77";
const TEST_SYM_KEY =
    "0653ca620c7b4990392e1c53c4a51c14a2840cd20f0f1524cf435b17b6fe988c";

const TEST_RELAY_OPTIONS = RelayerProtocolOptions(
  protocol: "irn",
  data: null,
);

const TEST_SESSION_METADATA = AppMetadata(
  name: "My App",
  description: "App that requests wallet signature",
  url: "http://myapp.com",
  icons: ["http://myapp.com/logo.png"],
);

const TEST_ETHEREUM_NAMESPACE = "eip155";

const TEST_ETHEREUM_CHAIN_A = '$TEST_ETHEREUM_NAMESPACE:1';

const TEST_ETHEREUM_CHAIN_B = '$TEST_ETHEREUM_NAMESPACE:137';

const TEST_ETHEREUM_ADDRESS = ["0x1d85568eEAbad713fBB5293B45ea066e552A90De"];

final TEST_ETHEREUM_ACCOUNT_A = '$TEST_ETHEREUM_CHAIN_A:$TEST_ETHEREUM_ADDRESS';

final TEST_ETHEREUM_ACCOUNT_B = '$TEST_ETHEREUM_CHAIN_B:$TEST_ETHEREUM_ADDRESS';

const TEST_CHAINS = [TEST_ETHEREUM_CHAIN_A, TEST_ETHEREUM_CHAIN_B];

final TEST_ACCOUNTS = [TEST_ETHEREUM_ACCOUNT_A, TEST_ETHEREUM_ACCOUNT_B];

const TEST_METHODS = [
  "personal_sign",
  "eth_signTypedData",
  "eth_sendTransaction"
];

const TEST_EVENTS = ["chainChanged", "accountsChanged"];

const TEST_DATE_NOW = 1649874082376;

const TEST_EXPIRY_1D = 1649960482376;

const TEST_EXPIRY_7D = 1650478882376;

const TEST_EXPIRY_30D = 1652466082376;

final TEST_SESSION = SessionStruct(
  expiry: TEST_EXPIRY_7D,
  topic: TEST_SESSION_TOPIC,
  relay: TEST_RELAY_OPTIONS,
  acknowledged: true,
  controller: TEST_KEY_PAIRS_A.publicKey,
  self: SessionPublicKeyMetadata(
    publicKey: TEST_KEY_PAIRS_A.publicKey,
    metadata: TEST_SESSION_METADATA,
  ),
  peer: SessionPublicKeyMetadata(
    publicKey: TEST_KEY_PAIRS_B.publicKey,
    metadata: TEST_SESSION_METADATA,
  ),
  requiredNamespaces: {
    TEST_ETHEREUM_NAMESPACE: ProposalRequiredNamespace(
      chains: TEST_CHAINS,
      methods: TEST_METHODS,
      events: TEST_EVENTS,
    ),
  },
  namespaces: {
    TEST_ETHEREUM_NAMESPACE: SessionNamespace(
      accounts: TEST_ACCOUNTS,
      methods: TEST_METHODS,
      events: TEST_EVENTS,
    ),
  },
);
