// ignore_for_file: constant_identifier_names

import 'package:wallet_connect/wc_utils/jsonrpc/models/models.dart';

// Constants

enum SdkErrorKey {
  INVALID_METHOD,
  INVALID_EVENT,
  INVALID_UPDATE_REQUEST,
  INVALID_EXTEND_REQUEST,
  INVALID_SESSION_SETTLE_REQUEST,
  UNAUTHORIZED_METHOD,
  UNAUTHORIZED_EVENT,
  UNAUTHORIZED_UPDATE_REQUEST,
  UNAUTHORIZED_EXTEND_REQUEST,
  USER_REJECTED,
  USER_REJECTED_CHAINS,
  USER_REJECTED_METHODS,
  USER_REJECTED_EVENTS,
  UNSUPPORTED_CHAINS,
  UNSUPPORTED_METHODS,
  UNSUPPORTED_EVENTS,
  UNSUPPORTED_ACCOUNTS,
  UNSUPPORTED_NAMESPACE_KEY,
  USER_DISCONNECTED,
  SESSION_SETTLEMENT_FAILED,
  WC_METHOD_UNSUPPORTED,
  NOT_INITIALIZED,
}

const SDK_ERRORS = {
  /* ----- INVALID (1xxx) ----- */
  SdkErrorKey.INVALID_METHOD: ErrorResponse(
    message: "Invalid method.",
    code: 1001,
  ),
  SdkErrorKey.INVALID_EVENT: ErrorResponse(
    message: "Invalid event.",
    code: 1002,
  ),
  SdkErrorKey.INVALID_UPDATE_REQUEST: ErrorResponse(
    message: "Invalid update request.",
    code: 1003,
  ),
  SdkErrorKey.INVALID_EXTEND_REQUEST: ErrorResponse(
    message: "Invalid extend request.",
    code: 1004,
  ),
  SdkErrorKey.INVALID_SESSION_SETTLE_REQUEST: ErrorResponse(
    message: "Invalid session settle request.",
    code: 1005,
  ),
  /* ----- UNAUTHORIZED (3xxx) ----- */
  SdkErrorKey.UNAUTHORIZED_METHOD: ErrorResponse(
    message: "Unauthorized method.",
    code: 3001,
  ),
  SdkErrorKey.UNAUTHORIZED_EVENT: ErrorResponse(
    message: "Unauthorized event.",
    code: 3002,
  ),
  SdkErrorKey.UNAUTHORIZED_UPDATE_REQUEST: ErrorResponse(
    message: "Unauthorized update request.",
    code: 3003,
  ),
  SdkErrorKey.UNAUTHORIZED_EXTEND_REQUEST: ErrorResponse(
    message: "Unauthorized extend request.",
    code: 3004,
  ),
  /* ----- REJECTED (5xxx) ----- */
  SdkErrorKey.USER_REJECTED: ErrorResponse(
    message: "User rejected.",
    code: 5000,
  ),
  SdkErrorKey.USER_REJECTED_CHAINS: ErrorResponse(
    message: "User rejected chains.",
    code: 5001,
  ),
  SdkErrorKey.USER_REJECTED_METHODS: ErrorResponse(
    message: "User rejected methods.",
    code: 5002,
  ),
  SdkErrorKey.USER_REJECTED_EVENTS: ErrorResponse(
    message: "User rejected events.",
    code: 5003,
  ),
  SdkErrorKey.UNSUPPORTED_CHAINS: ErrorResponse(
    message: "Unsupported chains.",
    code: 5100,
  ),
  SdkErrorKey.UNSUPPORTED_METHODS: ErrorResponse(
    message: "Unsupported methods.",
    code: 5101,
  ),
  SdkErrorKey.UNSUPPORTED_EVENTS: ErrorResponse(
    message: "Unsupported events.",
    code: 5102,
  ),
  SdkErrorKey.UNSUPPORTED_ACCOUNTS: ErrorResponse(
    message: "Unsupported accounts.",
    code: 5103,
  ),
  SdkErrorKey.UNSUPPORTED_NAMESPACE_KEY: ErrorResponse(
    message: "Unsupported namespace key.",
    code: 5104,
  ),
  /* ----- REASON (6xxx) ----- */
  SdkErrorKey.USER_DISCONNECTED: ErrorResponse(
    message: "User disconnected.",
    code: 6000,
  ),
  /* ----- FAILURE (7xxx) ----- */
  SdkErrorKey.SESSION_SETTLEMENT_FAILED: ErrorResponse(
    message: "Session settlement failed.",
    code: 7000,
  ),
  /* ----- PAIRING (10xxx) ----- */
  SdkErrorKey.WC_METHOD_UNSUPPORTED: ErrorResponse(
    message: "Unsupported wc_ method.",
    code: 10001,
  ),
};

enum InternalErrorKey {
  NOT_INITIALIZED,
  NO_MATCHING_KEY,
  RESTORE_WILL_OVERRIDE,
  RESUBSCRIBED,
  MISSING_OR_INVALID,
  EXPIRED,
  UNKNOWN_TYPE,
  MISMATCHED_TOPIC,
  NON_CONFORMING_NAMESPACES,
}

const INTERNAL_ERRORS = {
  InternalErrorKey.NOT_INITIALIZED: ErrorResponse(
    message: "Not initialized.",
    code: 1,
  ),
  InternalErrorKey.NO_MATCHING_KEY: ErrorResponse(
    message: "No matching key.",
    code: 2,
  ),
  InternalErrorKey.RESTORE_WILL_OVERRIDE: ErrorResponse(
    message: "Restore will override.",
    code: 3,
  ),
  InternalErrorKey.RESUBSCRIBED: ErrorResponse(
    message: "Resubscribed.",
    code: 4,
  ),
  InternalErrorKey.MISSING_OR_INVALID: ErrorResponse(
    message: "Missing or invalid.",
    code: 5,
  ),
  InternalErrorKey.EXPIRED: ErrorResponse(
    message: "Expired.",
    code: 6,
  ),
  InternalErrorKey.UNKNOWN_TYPE: ErrorResponse(
    message: "Unknown type.",
    code: 7,
  ),
  InternalErrorKey.MISMATCHED_TOPIC: ErrorResponse(
    message: "Mismatched topic.",
    code: 8,
  ),
  InternalErrorKey.NON_CONFORMING_NAMESPACES: ErrorResponse(
    message: "Non conforming namespaces.",
    code: 9,
  ),
};

// Utilities
ErrorResponse getInternalError(InternalErrorKey key, {String? context}) {
  final error = INTERNAL_ERRORS[key]!;
  return ErrorResponse(
    message: context != null ? '${error.message} $context' : error.message,
    code: error.code,
  );
}

ErrorResponse getSdkError(SdkErrorKey key, {String? context}) {
  final error = SDK_ERRORS[key]!;
  return ErrorResponse(
    message: context != null ? '${error.message} $context' : error.message,
    code: error.code,
  );
}
