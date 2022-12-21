const SDK_TYPE = "dart";

// -- rpcUrl ----------------------------------------------//

String getJavascriptOS() {
  // final info = detect();
  // if (info == null)
  // return "unknown";
  // final os = info.os ? info.os.replace(" ", "").toLowerCase() : "unknown";
  // if (info.type == "browser") {
  //   return [os, info.name, info.version].join("-");
  // }
  // return [os, info.version].join("-");
  return "unknown"; // TODO: Remove
}

getJavascriptID() {
  // final env = getEnvironment();
  // return env === ENV_MAP.browser ? [env, getLocation()?.host || "unknown"].join(":") : env;
  return "unknown"; // TODO: Remove
}

String formatUA(String protocol, int version, String sdkVersion) {
  final os = getJavascriptOS();
  final id = getJavascriptID();
  return [
    [protocol, version].join("-"),
    [SDK_TYPE, sdkVersion].join("-"),
    os,
    id
  ].join("/");
}

formatRelayRpcUrl({
  required String protocol,
  required int version,
  required String auth,
  required String relayUrl,
  required String sdkVersion,
  String? projectId,
}) {
  final uri = Uri.parse(relayUrl);
  final queryParams = Uri.splitQueryString(uri.query);
  final ua = formatUA(protocol, version, sdkVersion);
  final newQueryParams = {'auth': auth, 'ua': ua, 'projectId': projectId ?? ''};
  queryParams.addAll(newQueryParams);
  return uri.replace(queryParameters: queryParams).toString();
}
