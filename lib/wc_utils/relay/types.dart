class RelayJsonRpcMethods {
  final String publish;
  final String subscribe;
  final String subscription;
  final String unsubscribe;

  const RelayJsonRpcMethods({
    required this.publish,
    required this.subscribe,
    required this.subscription,
    required this.unsubscribe,
  });
}

class RelayJsonRpcSubscribeParams {
  final String topic;

  const RelayJsonRpcSubscribeParams({
    required this.topic,
  });
}

class RelayJsonRpcPublishParams {
  final String topic;
  final String message;
  final int ttl;
  final bool? prompt;
  final int? tag;

  const RelayJsonRpcPublishParams({
    required this.topic,
    required this.message,
    required this.ttl,
    this.prompt,
    this.tag,
  });
}

class RelayJsonRpcSubscriptionData {
  final String topic;
  final String message;

  const RelayJsonRpcSubscriptionData({
    required this.topic,
    required this.message,
  });
}

class RelayJsonRpcSubscriptionParams {
  final String id;
  final RelayJsonRpcSubscriptionData data;

  const RelayJsonRpcSubscriptionParams({
    required this.id,
    required this.data,
  });
}

class RelayJsonRpcUnsubscribeParams {
  final String id;
  final String topic;

  const RelayJsonRpcUnsubscribeParams({
    required this.id,
    required this.topic,
  });
}
