import 'package:barcode/barcode.dart';
import 'package:example_dapp/main.dart';
import 'package:example_dapp/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet_connect/wallet_connect.dart';

class UriView extends StatefulWidget {
  final SignClient signClient;
  final String connectionUri;

  const UriView({
    super.key,
    required this.signClient,
    required this.connectionUri,
  });

  @override
  State<UriView> createState() => _UriViewState();
}

class _UriViewState extends State<UriView> {
  late String barcodeSvg;

  @override
  void initState() {
    barcodeSvg = Barcode.qrCode().toSvg(
      widget.connectionUri,
      height: 200.0,
      width: 200.0,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppBar(
          title: 'Connect',
          alignment: Alignment.center,
          textAlign: TextAlign.center,
          borderRadius: BorderRadius.circular(10.0),
          trailing: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close),
              color: Colors.grey,
            ),
          ],
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
              child: SvgPicture.string(barcodeSvg),
            ),
          ),
        ),
        const Text(
          'or connect with Wallet Connect uri',
          style: TextStyle(color: Colors.grey),
        ),
        Container(
          height: 48.0,
          width: double.infinity,
          margin: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [
              primaryColor,
              secondaryColor,
            ]),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.connectionUri)).then(
                  (_) =>
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Uri copied.'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(milliseconds: 500),
                      )));
            },
            style: TextButton.styleFrom(
              primary: Colors.white,
              textStyle: const TextStyle(fontWeight: FontWeight.w500),
            ),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Copy URI',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
