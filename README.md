# Getting started

<br>

### This SDK is built with inspiration from official [WalletConnect SDK 2.0](https://docs.walletconnect.com/2.0).

<br>

# Index

1. [Usage](#usage)
2. [Initialization](#initialization)
3. [Pairing via QR](#pairing-via-qr-code)
4. [Pairing Via URI](#pairing-via-uri)
5. [Session Approval and Rejection](#session-approval-and-rejection)
6. [Responding to Session Requests](#responding-to-session-requests)
7. [Delete Session](#session-delete)
8. [Extend Session](#extend-a-session)
9. [Update Session](#updating-a-session​)
10. [Session Emit](#emit-a-session)

## Usage

To configure your app to use latest version of `wallet-connect-v2`, see [example](https://github.com/orange-wallet/wallet-connect-dart)

<br>

## Initialization

Create a new instance of `SignClient` and initialize it with a `projectId`, `relayUrl` and `metadata` created from installation.
You can opt to use `Hive` to save session details or they will be saved in memory by default.

```
final _signClient = await SignClient.init(
      projectId: "PROJECY_ID",
      relayUrl: "RELAY_URL" // or use defalut "wss://relay.walletconnect.com",
      metadata: const AppMetadata(
        name: "Demo app",
        description: "Demo Client as Wallet/Peer",
        url: "www.walletconnect.com",
        icons: [],
      ),
      database: 'HIVE_DB_NAME', // optional, if empty all session data will be stored in memory
    );
```

<br>

## Pairing via QR code

We have used [ScanView](https://pub.dev/packages/scan) for this you can use any other package as well.

1. Scan the QR code and get the data
   ```
   ScanView(
     controller: ScanController(),
     scanAreaScale: 1,
     scanLineColor: Colors.green.shade400,
     onCapture: (data) {
       _qrScanHandler(data);
     },
   );
   ```
2. Convert the Scanned data to URI
   ```
   _qrScanHandler(String value) {
     if (Uri.tryParse(value) != null) {
       _signClient.pair(value);
     }
   }
   ```

<br>

## Pairing via URI

Directly use `pair` functionality from `SignClient` instance

```
await _signClient.pair(value);
```

<br>

### Session Approval and Rejection

The `SignClientEvent.SESSION_PROPOSAL` event is emitted when a dapp initiates a new session with a user's wallet. The event will include a proposal object with information about the dapp and requested permissions. The wallet should display a prompt for the user to approve or reject the session. If approved, call approveSession and pass in the proposal.id and requested namespaces.

You can listen for this event while initilizing app:

```
_signClient.on(SignClientEvent.SESSION_PROPOSAL.value, (data) async {
      final eventData = (data as Map<String, dynamic>);
      final id = eventData['id'] as int;
      final proposal = ProposalStruct.fromJson(eventData['params'] as Map<String, dynamic>);
      // add custom popup to either approve or rejet this session here or use `SessionRequestView` from our example
      const approve = true;
      if(approve)
      {
        final params = SessionApproveParams(
              id: id,
              namespaces: namespaces,
            );
        _signClient.approve(params);
      }
      else {
        final params = SessionRejectParams(
              id: id,
              reason: formatErrorMessage(
                  error: getSdkError(SdkErrorKey.USER_DISCONNECTED)),
            );
        _signClient.reject(params);
      }
    });
```

<br>

## Responding to Session Requests

The `SignClientEvent.SESSION_REQUEST` event is triggered when a dapp sends a request to the wallet for a specific action, such as signing a transaction. This event is emitted by the dapp and received by the wallet. To respond to the request, wallets should call the specific required sign function and pass in details from the request. You can then approve or reject the request based on the response.

```
_signClient.on(SignClientEvent.SESSION_REQUEST.value, (data) async {
      final eventData = (data as Map<String, dynamic>);
      log('DATA $eventData');
      final id = eventData['id'] as int;
      final sessionRequest = SessionRequestParams.fromJson(
        eventData['params'] as Map<String, dynamic>,
      );

      if (sessionRequest.request.method == Eip155Methods.PERSONAL_SIGN.value) {
        final requestParams = sessionRequest.request.params as List<String>;
        final dataToSign = requestParams[0];
        final address = requestParams[1];
        // use specific function for personal sign
      }
    });
```

<br>

## Session Delete

If either the dapp or the wallet decides to disconnect the session, the `SignClientEvent.SESSION_DELETE` event will be emitted. The wallet should listen for this event in order to update the UI.

To disconnect a session from the wallet, call the `disconnect` function and pass in the topic and reason. You can optionally send the reason for disconnect to dapp.

```
await _signClient.disconnect(topic: "TOPIC");
```

Here is how to listen to `SignClientEvent.SESSION_DELETE` event:

```
_signClient.on(SignClientEvent.SESSION_DELETE.value, (data) async {
      final eventData = JsonRpcRequest.fromJson(
        data as Map<String, dynamic>,
        (v) => RequestSessionDelete.fromJson(v as Map<String, dynamic>),
      );
      log('SESSION_DELETE: ${eventData.toJson()}');
      // Do other thing with the info.
    });
```

<br>

## Extend a Session

To extend the session, call the `extend` method and pass in the new topic. The `SignClientEvent.SESSION_UPDATE` event will be emitted from the wallet.

```
await _signClient.extend("TOPIC");
```

<br>

## Updating a Session​

The `SignClientEvent.SESSION_UPDATE` event is emitted from the wallet when the session is updated by calling `update`.
To update a session, pass in the new `SessionUpdateParams`

```
await _signClient.update(params);
```

<br>

## Emit a Session

To emit sesssion events, call the `emit` and pass in the params. It takes `SessionEmitParams` as a parameter.

```
SessionEmitParams params = SessionEmitParams(
    topic: "TOPIC",
    event: SessionEmitEvent(
      name: "NAME",
      data: ["DATA_1"],
    ),
    chainId: "CHAIN_ID");
await _signClient.emit(params);
```

<br>
