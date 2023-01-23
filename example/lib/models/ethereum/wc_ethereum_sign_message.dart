enum WCSignType { MESSAGE, PERSONAL_MESSAGE }

class WCEthereumSignMessage {
  final List<String> raw;
  final WCSignType type;

  const WCEthereumSignMessage({
    required this.raw,
    required this.type,
  });

  String? get data {
    switch (type) {
      case WCSignType.MESSAGE:
        return raw[1];
      case WCSignType.PERSONAL_MESSAGE:
        return raw[0];
      default:
        return null;
    }
  }
}
