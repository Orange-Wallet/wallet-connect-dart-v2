import 'package:wallet_connect/sign/engine/types.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/utils/error.dart';

const SDK_TYPE = "js";

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
  return "darwin-16.14.0"; // TODO: Remove
}

String getJavascriptID() {
  // final env = getEnvironment();
  // return env === ENV_MAP.browser ? [env, getLocation()?.host || "unknown"].join(":") : env;
  return "node"; // TODO: Remove
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

String formatRelayRpcUrl({
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
  final Map<String, String> newQueryParams = {
    'auth': auth,
    if (projectId?.isNotEmpty ?? false) 'projectId': projectId!,
    'ua': ua,
  };
  queryParams.addAll(newQueryParams);
  return uri.replace(queryParameters: queryParams).toString();
}

// -- array ------------------------------------------------- //
bool hasOverlap(List<dynamic> a, List<dynamic> b) {
  final matches = a.where((x) => b.contains(x));
  return matches.length == a.length;
}

// -- time ------------------------------------------------- //

int calcExpiry({required int ttl, int? now}) {
  return ((now ?? DateTime.now().millisecondsSinceEpoch) + (ttl * 1000)) ~/
      1000;
}

// TODO: Reverify logic
bool isExpired(int expiry) {
  return (DateTime.now().millisecondsSinceEpoch ~/ 1000) >= (expiry * 1000);
}

// -- expirer --------------------------------------------- //

String formatExpirerTarget(String type, dynamic value) {
  if (value is String && value.startsWith('$type:')) return value;
  if (type.toLowerCase() == "topic") {
    if (value is! String) {
      throw WCException('Value must be String for expirer target type: topic');
    }
    return 'topic:$value';
  } else if (type.toLowerCase() == "id") {
    if (value is! int) {
      throw WCException('Value must be int for expirer target type: id');
    }
    return 'id:$value';
  }
  throw WCException('Unknown expirer target type: $type');
}

String formatTopicTarget(String topic) {
  return formatExpirerTarget("topic", topic);
}

String formatIdTarget(int id) {
  return formatExpirerTarget("id", id);
}

class ExpirerTarget {
  final String? topic;
  final int? id;

  const ExpirerTarget({this.topic, this.id});
}

ExpirerTarget parseExpirerTarget(String target) {
  final type = target.split(":")[0];
  final value = target.split(":")[1];
  int? id;
  String? topic;
  if (type == "topic") {
    topic = value;
  } else if (type == "id" && int.tryParse(value) != null) {
    id = int.tryParse(value);
  } else {
    throw WCException(
        'Invalid target, expected id:number or topic:string, got $type:$value');
  }

  return ExpirerTarget(id: id, topic: topic);
}

// -- events ---------------------------------------------- //

String engineEvent(EngineTypesEvent event, [dynamic id]) {
  return '${event.value}${id != null ? ':$id' : ''}';
}
