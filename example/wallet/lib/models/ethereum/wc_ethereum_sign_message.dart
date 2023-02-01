enum WCSignType {
  MESSAGE,
  PERSONAL_MESSAGE,
  TYPED_MESSAGE_V1,
  TYPED_MESSAGE_V3,
  TYPED_MESSAGE_V4
}

class WCEthereumSignMessage {
  final String data;
  final String address;
  final WCSignType type;

  const WCEthereumSignMessage({
    required this.data,
    required this.address,
    required this.type,
  });
}
