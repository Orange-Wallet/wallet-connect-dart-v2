<div align="center">
<img src="https://i.imgur.com/fwGGvJj.png" alt="Wallet Connect Logo" width="70"/>
<h1>Wallet Connect</h1>
</div>

### [Wallet Connect SDK](https://docs.walletconnect.com/2.0) made in ❤️ with dart.

<br>

# Getting started

To configure your app use latest version of `wallet_connect_dart_v2`, see [pub.dev](https://pub.dev/packages/wallet_connect_dart_v2)

**_Note: In order to use wallet_connect_dart_v2 alongside the legacy v1 sdk, see [wallet_connect](https://pub.dev/packages/wallet_connect)._**

- [Dapp Usage](#dapp-usage)
- [Wallet Usage](#wallet-usage)

<br>

# Dapp Usage

For detailed implementation of dapp usage, see [example-dapp](https://github.com/Orange-Wallet/wallet-connect-dart-v2/tree/master/example/dapp).

<br>

# Wallet Usage

For detailed implementation of wallet usage, see [example-wallet](https://github.com/Orange-Wallet/wallet-connect-dart-v2/tree/master/example/wallet).

1. [Initialization](#initialization)
2. [Pairing via QR](#pairing-via-qr-code)
3. [Pairing Via URI](#pairing-via-uri)
4. [Responding to Session Proposal](#responding-to-session-proposal)
5. [Responding to Dapp Requests](#responding-to-dapp-requests)
6. [Responding to Dapp Events](#responding-to-dapp-events)
7. [Responding to Ping](#responding-to-ping)
8. [Responding to Session Delete](#responding-to-session-delete​)
9. [Sending Requests to Dapp](#sending-requests-to-dapp)

<br>

## Initialization

```dart
import 'package:wallet_connect_dart_v2/wallet_connect_dart_v2.dart';
```

```dart
final signClient = await SignClient.init(
      projectId: "PROJECY_ID",
      relayUrl: "RELAY_URL", // or leaving it empty, uses default "wss://relay.walletconnect.com"
      metadata: const AppMetadata(
        name: "Demo app",
        description: "Demo Client as Wallet/Peer",
        url: "www.walletconnect.com",
        icons: [],
      ),
      database: 'DB_NAME', // optional, if empty all session data will be stored in memory
    );
```

<br>

## Pairing via QR code

We have used [ScanView](https://pub.dev/packages/scan) for this you can use any other package as well.

Scan the QR code to get pairing URI.

```dart
ScanView(
  controller: ScanController(),
  onCapture: (data) {
       if (Uri.tryParse(value) != null) {
         signClient.pair(value);
     }
  },
);
```

<br>

## Pairing via URI

Directly use `pair` functionality from `SignClient` instance

```dart
await signClient.pair(value);
```

<br>

## Responding to Session Proposal

The `SignClientEvent.SESSION_PROPOSAL` event is emitted when a dapp initiates a new session with a user's wallet. The event will include a proposal object with information about the dapp and requested permissions. The wallet should display a prompt for the user to approve or reject the session. If approved, call approveSession and pass in the proposal.id and requested namespaces.

You can listen for this event while initializing client:

```dart
signClient.on(SignClientEvent.SESSION_PROPOSAL.value, (data) {
      final eventData = data as SignClientEventParams<RequestSessionPropose>;

      // Show session proposal data to the user i.e. in a popup with options to approve / reject it

      const approve = true;
      // On Approve Session Proposal
      if(approve) {
        //
        final SessionNamespaces namespaces = {
          // Provide the namespaces and chains (e.g. `eip155` for EVM-based chains) being requested by dapp.
          "eip155": SessionNamespace(
              // `accounts` addresses need to be passed from the wallet side int the specified format as per the number of chains being requested by dapp
              accounts: ["eip155:1:0x0000000000..., eip155:10:0x0000000000..."],
              // `methods and `events` Can be accessed at `eventData.params!.requiredNamespaces`
              methods: [
                  "eth_sendTransaction",
                  "eth_signTransaction",
                  "eth_sign",
                  "personal_sign",
                  "eth_signTypedData",
              ],
              events: ["chainChanged", "accountsChanged"],
          )
        };

        final params = SessionApproveParams(
              id: eventData.id!,
              namespaces: namespaces,
            );
        signClient.approve(params);
      }
      // Or Reject Session Proposal
      else {
        final params = SessionRejectParams(
              id: eventData.id!,
              reason: formatErrorMessage(
                  error: getSdkError(SdkErrorKey.USER_DISCONNECTED),
              ),
            );
        signClient.reject(params);
      }
    });
```

<br>

## Responding to Dapp Requests

The `SignClientEvent.SESSION_REQUEST` event is triggered when a dapp sends a request to the wallet for a specific action, such as signing a transaction. This event is emitted by the dapp and received by the wallet. To respond to the request, wallets should call the specific required sign function and pass in details from the request. You can then approve or reject the request based on the response.

```dart
signClient.on(SignClientEvent.SESSION_REQUEST.value, (data) async {
      final eventData = data as SignClientEventParams<RequestSessionRequest>;
      final String method = eventData.params!.request.method;

      // Example handling some methods from EVM-based chains
      if (method == "personal_sign") {
        final requestParams = eventData.params!.request.params[0];
        final dataToSign = requestParams["data"];
        final address = requestParams["to"];

        // Handle request params to generate necessary result and send back the response to dapp.
        final signedDataHex = personalSign(dataToSign, address);
        // Approve the request
        signClient!.respond(
          SessionRespondParams(
            topic: eventData.topic!,
            response: JsonRpcResult<String>(
              id: eventData.id!,
              result: signedDataHex,
            ),
          ),
        );
        // Or Reject the request with error
        _signClient!.respond(SessionRespondParams(
          topic: eventData.topic!,
          response: JsonRpcError(id: eventData.id!),
        ));
      } else if (method == "eth_sign") {
        // Handle `eth_sign`
      } else if (method == "eth_signTypedData") {
        // Handle `eth_signTypedData`
      } else if (method == "eth_sendTransaction") {
        final requestParams = eventData.params!.request.params[0];
        // Handle `eth_sendTransaction`
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Send transaction'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    // You can use web3dart package to excecute transaction
                    // then pass it in params to respond
                    final txhash = _web3client.sendTransaction();
                    
                    signClient.respond(
                      SessionRespondParams(
                        topic: eventData.topic!,
                        response: JsonRpcResult<String>(
                          id: eventData.id!,
                          result: txhash,
                        ),
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text('Accept'),
                ),
                TextButton(
                  onPressed: () {
                    signClient.respond(SessionRespondParams(
                      topic: eventData.topic!,
                      response: JsonRpcError(id: eventData.id!),
                    ));
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      } else if (method == "eth_signTransaction") {
        // Handle `eth_signTransaction`
      }
    });
```

<br>

## Responding to Dapp Events

```dart
signClient!.on(SignClientEvent.SESSION_EVENT.value, (data) {
      final eventData = data as SignClientEventParams<RequestSessionEvent>;
      // Handle events request
    });
```

<br>

## Responding to Ping

```dart
signClient!.on(SignClientEvent.SESSION_PING.value, (data) {
      final eventData = data as SignClientEventParams<void>;
      // Handle Ping request
    });
```

<br>

## Responding to Session Delete

```dart
 signClient!.on(SignClientEvent.SESSION_DELETE.value, (data) {
      final eventData = data as SignClientEventParams<void>;
      // Handle Session Delete request
    });
```

<br>

## Sending Requests to Dapp

### Session Delete

If either the dapp or the wallet decides to disconnect the session, the `SignClientEvent.SESSION_DELETE` event will be emitted. The wallet should listen for this event in order to update the UI.

To disconnect a session from the wallet, call the `disconnect` function and pass in the topic and reason. You can optionally send the reason for disconnect to dapp.

```dart
await signClient.disconnect(topic: "TOPIC");
```

<br>

### Extend a Session

To extend the session, call the `extend` method and pass in the new topic. The `SignClientEvent.SESSION_UPDATE` event will be emitted from the wallet.

```dart
await signClient.extend("TOPIC");
```

<br>

### Updating a Session​

The `SignClientEvent.SESSION_UPDATE` event is emitted from the wallet when the session is updated by calling `update`.
To update a session, pass in the new `SessionUpdateParams`

```dart
await signClient.update(params);
```

<br>

### Emit a Session Event

To emit sesssion events, call the `emit` and pass in the params. It takes `SessionEmitParams` as a parameter.

```dart
final SessionEmitParams params = SessionEmitParams(
    topic: "TOPIC",
    event: SessionEmitEvent(
      name: "NAME",
      data: ["DATA_1"],
    ),
    chainId: "CHAIN_ID");
await signClient.emit(params);
```

<br>
