import 'package:example_wallet/main.dart';
import 'package:example_wallet/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scan/scan.dart';
import 'package:wallet_connect_dart_v2/wallet_connect_dart_v2.dart';

class ConnectPage extends StatefulWidget {
  final SignClient signClient;
  final bool enableScanView;

  const ConnectPage({
    super.key,
    required this.signClient,
    this.enableScanView = false,
  });

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  late TextEditingController _uriController;

  late bool _scanView;

  @override
  void initState() {
    _scanView = widget.enableScanView;
    _uriController = TextEditingController();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ConnectPage oldWidget) {
    _scanView = widget.enableScanView;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CustomAppBar(
          title: 'Wallet Connect',
          alignment: Alignment.center,
          textAlign: TextAlign.center,
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
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Stack(
                        children: [
                          ScanView(
                            controller: ScanController(),
                            scanAreaScale: 1,
                            scanLineColor: Colors.green.shade400,
                            onCapture: (data) {
                              _qrScanHandler(data);
                            },
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _scanView = false;
                                });
                              },
                              icon: const Icon(Icons.close),
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
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
}
