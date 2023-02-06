import 'package:platform_info/platform_info.dart';
import 'package:universal_html/html.dart' as html;
import 'package:walletconnect_v2/sign/engine/models.dart';
import 'package:walletconnect_v2/wc_utils/jsonrpc/utils/error.dart';
import 'package:web_browser_detect/web_browser_detect.dart';

const SDK_TYPE = "dart";
const ENV = "flutter";

// -- rpcUrl ----------------------------------------------//

String getOS() {
  final os = platform.operatingSystem.name.toLowerCase();
  if (platform.isWeb) {
    final info = Browser.detectOrNull();
    return [os, info!.browser, info.version].join("-");
  } else {
    return os;
  }
}

String getID() {
  return platform.isWeb ? [ENV, html.window.location.host].join("-") : ENV;
}

String formatUA(String protocol, int version, String sdkVersion) {
  final os = getOS();
  final id = getID();
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

bool isExpired(int expiry) {
  return (DateTime.now().millisecondsSinceEpoch) >= (expiry * 1000);
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

String engineEvent(EngineEvent event, [dynamic id]) {
  return '${event.value}${id != null ? ':$id' : ''}';
}
