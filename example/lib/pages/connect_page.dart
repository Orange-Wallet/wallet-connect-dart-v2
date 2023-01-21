import 'dart:developer';

import 'package:example/main.dart';
import 'package:example/utils/eip155_data.dart';
import 'package:example/widgets/custom_app_bar.dart';
import 'package:example/widgets/session_request_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scan/scan.dart';
import 'package:wallet_connect/sign/engine/models.dart';
import 'package:wallet_connect/sign/sign-client/client/models.dart';
import 'package:wallet_connect/sign/sign-client/client/sign_client.dart';
import 'package:wallet_connect/sign/sign-client/jsonrpc/models.dart';
import 'package:wallet_connect/sign/sign-client/proposal/models.dart';
import 'package:wallet_connect/utils/error.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/models/models.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/format.dart';

class ConnectPage extends StatefulWidget {
  final SignClient signClient;

  const ConnectPage({
    super.key,
    required this.signClient,
  });

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  late TextEditingController _uriController;

  // final _web3client = Web3Client(rpcUri, http.Client());

  late bool _scanView;

  @override
  void initState() {
    _scanView = false;
    _uriController = TextEditingController();
    _initializeListeners();
    super.initState();
  }

  _initializeListeners() async {
    widget.signClient.on(SignClientEvent.SESSION_PROPOSAL.value, (data) async {
      final eventData = JsonRpcRequest.fromJson(
        data as Map<String, dynamic>,
        (v) => RequestSessionPropose.fromJson(v as Map<String, dynamic>),
      );

      log('SESSION_PROPOSAL: ${eventData.toJson()}');

      // _onSessionRequest(eventData.id, eventData.params!);
    });

    widget.signClient.on(SignClientEvent.SESSION_REQUEST.value, (data) async {
      final eventData = JsonRpcRequest.fromJson(
        data as Map<String, dynamic>,
        (v) => RequestSessionRequest.fromJson(v as Map<String, dynamic>),
      );
      log('SESSION_REQUEST: ${eventData.toJson()}');

      if (eventData.params!.request.method ==
          Eip155Methods.PERSONAL_SIGN.value) {
        final requestParams = eventData.params!.request.params as List<String>;
        final dataToSign = requestParams[0];
        final address = requestParams[1];
      }
    });

    widget.signClient.on(SignClientEvent.SESSION_EVENT.value, (data) async {
      final eventData = JsonRpcRequest.fromJson(
        data as Map<String, dynamic>,
        (v) => RequestSessionEvent.fromJson(v as Map<String, dynamic>),
      );
      log('SESSION_EVENT: ${eventData.toJson()}');
    });

    widget.signClient.on(SignClientEvent.SESSION_PING.value, (data) async {
      final eventData = JsonRpcRequest.fromJson(
        data as Map<String, dynamic>,
        (v) => v,
      );
      log('SESSION_PING: ${eventData.toJson()}');
    });

    widget.signClient.on(SignClientEvent.SESSION_DELETE.value, (data) async {
      final eventData = JsonRpcRequest.fromJson(
        data as Map<String, dynamic>,
        (v) => RequestSessionDelete.fromJson(v as Map<String, dynamic>),
      );
      log('SESSION_DELETE: ${eventData.toJson()}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CustomAppBar(
          title: 'Wallet Connect',
          alignment: Alignment.center,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, .0, 20.0, 20.0),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: _scanView
                  ? ScanView(
                      controller: ScanController(),
                      scanAreaScale: 1,
                      scanLineColor: Colors.green.shade400,
                      onCapture: (data) {
                        _qrScanHandler(data);
                      },
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_2_rounded,
                          size: 100.0,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(height: 16.0),
                        Container(
                          height: 42.0,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [primaryColor, secondaryColor]),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _scanView = true;
                              });
                            },
                            style: TextButton.styleFrom(
                              primary: Colors.white,
                              textStyle:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('Scan QR code'),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const Text(
          'or connect with Wallet Connect uri',
          style: TextStyle(color: Colors.grey),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextFormField(
            controller: _uriController,
            onTap: () {
              Clipboard.getData('text/plain').then((value) {
                if (_uriController.text.isEmpty &&
                    value?.text != null &&
                    Uri.tryParse(value!.text!) != null) {
                  _uriController.text = value.text!;
                }
              });
            },
            decoration: InputDecoration(
              focusColor: secondaryColor,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300, width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: secondaryColor, width: 2.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300, width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              hintText: 'Enter uri',
              suffixIcon: Container(
                margin: const EdgeInsets.only(right: 5.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [primaryColor, secondaryColor]),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: TextButton(
                  onPressed: () {
                    _qrScanHandler(_uriController.text);
                  },
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Connect'),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }

  _qrScanHandler(String value) {
    if (Uri.tryParse(value) != null) {
      widget.signClient.pair(value);
    }
  }

  _connectToPreviousSession() {
    // final _sessionSaved = _prefs.getString('session');
    // debugPrint('_sessionSaved $_sessionSaved');
    // _sessionStore = _sessionSaved != null
    //     ? WCSessionStore.fromJson(jsonDecode(_sessionSaved))
    //     : null;
    // if (_sessionStore != null) {
    //   debugPrint('_sessionStore $_sessionStore');
    //   widget.signClient.connectFromSessionStore(_sessionStore!);
    // } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('No previous session found.'),
    ));
    // }
  }

  _onSwitchNetwork(int id, int chainId) async {
    // await widget.signClient.updateSession(chainId: chainId);
    // widget.signClient.approveRequest<Null>(id: id, result: null);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Changed network to $chainId.'),
    ));
  }

  _onSessionRequest(int id, ProposalStruct proposal) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: SessionRequestView(
          proposal: proposal,
          onApprove: (namespaces) async {
            final params = SessionApproveParams(
              id: id,
              namespaces: namespaces,
            );
            //  final approved = await
            widget.signClient.approve(params);
            // await approved.acknowledged;
            Navigator.pop(context);
          },
          onReject: () {
            widget.signClient.reject(SessionRejectParams(
              id: id,
              reason: formatErrorMessage(
                  error: getSdkError(SdkErrorKey.USER_DISCONNECTED)),
            ));
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  _onSessionError(dynamic message) {
    showDialog(
      context: context,
      builder: (_) {
        return SimpleDialog(
          title: Text("Error"),
          contentPadding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('Some Error Occured. $message'),
            ),
            Row(
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('CLOSE'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  _onSessionClosed(int? code, String? reason) {
    showDialog(
      context: context,
      builder: (_) {
        return SimpleDialog(
          title: Text("Session Ended"),
          contentPadding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('Some Error Occured. ERROR CODE: $code'),
            ),
            if (reason != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('Failure Reason: $reason'),
              ),
            Row(
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('CLOSE'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
