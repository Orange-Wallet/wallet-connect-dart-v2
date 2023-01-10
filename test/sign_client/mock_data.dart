import 'package:wallet_connect/core/core/types.dart';
import 'package:wallet_connect/core/relayer/types.dart';
import 'package:wallet_connect/sign/sign-client/proposal/types.dart';
import 'package:wallet_connect/sign/sign-client/session/types.dart';

const TEST_RELAY_URL = "ws://0.0.0.0:5555";

const TEST_RELAY_URL_US = "wss://us-east-1.relay.walletconnect.com";
const TEST_RELAY_URL_EU = "wss://eu-central-1.relay.walletconnect.com";
const TEST_RELAY_URL_AP = "wss://ap-southeast-1.relay.walletconnect.com";

// See https://github.com/WalletConnect/push-webhook-test-server
const TEST_WEBHOOK_ENDPOINT = "https://webhook-push-test.walletconnect.com/";

const TEST_PROJECT_ID = "";

const TEST_SIGN_CLIENT_NAME_A = "client_a";
const TEST_APP_METADATA_A = Metadata(
  name: "App A (Proposer)",
  description: "Description of Proposer App run by client A",
  url: "https://walletconnect.com",
  icons: ["https://avatars.githubusercontent.com/u/37784886"],
);

const TEST_SIGN_CLIENT_NAME_B = "client_b";
const TEST_APP_METADATA_B = Metadata(
  name: "App B (Responder)",
  description: "Description of Responder App run by client B",
  url: "https://walletconnect.com",
  icons: ["https://avatars.githubusercontent.com/u/37784886"],
);

const TEST_RELAY_PROTOCOL = "irn";
const TEST_RELAY_OPTIONS = RelayerTypesProtocolOptions(
  protocol: TEST_RELAY_PROTOCOL,
);

const TEST_ETHEREUM_CHAIN = "eip155:1";
const TEST_ARBITRUM_CHAIN = "eip155:42161";
const TEST_AVALANCHE_CHAIN = "eip155:43114";

const TEST_CHAINS = [
  TEST_ETHEREUM_CHAIN,
  TEST_ARBITRUM_CHAIN,
  TEST_AVALANCHE_CHAIN,
];
const TEST_METHODS = [
  "eth_sendTransaction",
  "eth_signTransaction",
  "personal_sign",
  "eth_signTypedData",
];
const TEST_EVENTS = ["chainChanged", "accountsChanged"];

const TEST_ETHEREUM_ADDRESS = "0x3c582121909DE92Dc89A36898633C1aE4790382b";

const TEST_ETHEREUM_ACCOUNT = '${TEST_ETHEREUM_CHAIN}:${TEST_ETHEREUM_ADDRESS}';
const TEST_ARBITRUM_ACCOUNT = '${TEST_ARBITRUM_CHAIN}:${TEST_ETHEREUM_ADDRESS}';
const TEST_AVALANCHE_ACCOUNT =
    '${TEST_AVALANCHE_CHAIN}:${TEST_ETHEREUM_ADDRESS}';

const TEST_ACCOUNTS = [
  TEST_ETHEREUM_ACCOUNT,
  TEST_ARBITRUM_ACCOUNT,
  TEST_AVALANCHE_ACCOUNT,
];

const ProposalTypesRequiredNamespaces TEST_REQUIRED_NAMESPACES = {
  'eip155': ProposalTypesRequiredNamespace(
    methods: TEST_METHODS,
    chains: TEST_CHAINS,
    events: TEST_EVENTS,
  ),
};

const SessionTypesNamespaces TEST_NAMESPACES = {
  'eip155': SessionTypesNamespace(
    methods: TEST_METHODS,
    accounts: TEST_ACCOUNTS,
    events: TEST_EVENTS,
  ),
};
