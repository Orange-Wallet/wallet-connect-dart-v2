class SubscriberEvents {
  SubscriberEvents._();

  static const String created = "subscription_created";
  static const String deleted = "subscription_deleted";
  static const String expired = "subscription_expired";
  static const String disabled = "subscription_disabled";
  static const String sync = "subscription_sync";
  static const String resubscribed = "subscription_resubscribed";
}

const SUBSCRIBER_DEFAULT_TTL = 30 * 24 * 60 * 60; // 1month in sec

const SUBSCRIBER_CONTEXT = "subscription";

const SUBSCRIBER_STORAGE_VERSION = "0.3";

const PENDING_SUB_RESOLUTION_TIMEOUT = 5 * 1000; // 5sec in ms
