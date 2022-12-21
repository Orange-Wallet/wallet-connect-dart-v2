const HTTP_REGEX = "^https?:";

const WS_REGEX = "^wss?:";

String? getUrlProtocol(String url) {
  final matches = RegExp(r'^\w+:', caseSensitive: false).allMatches(url);
  return matches.isEmpty ? null : matches.first.group(0);
}

bool matchRegexProtocol(String url, String regex) {
  final protocol = getUrlProtocol(url);
  if (protocol == null) return false;
  return RegExp(regex).hasMatch(protocol);
}

bool isHttpUrl(String url) {
  return matchRegexProtocol(url, HTTP_REGEX);
}

bool isWsUrl(String url) {
  return matchRegexProtocol(url, WS_REGEX);
}

bool isLocalhostUrl(String url) {
  return RegExp(r'wss?://localhost(:d{2,5})?').hasMatch(url);
}
