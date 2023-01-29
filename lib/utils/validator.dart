import 'package:wallet_connect/core/relayer/models.dart';
import 'package:wallet_connect/sign/sign-client/proposal/models.dart';
import 'package:wallet_connect/sign/sign-client/session/models.dart';
import 'package:wallet_connect/utils/error.dart';
import 'package:wallet_connect/utils/misc.dart';
import 'package:wallet_connect/utils/namespaces.dart';
import 'package:wallet_connect/wc_utils/jsonrpc/models/models.dart';

class ErrorObject {
  final String message;
  final int code;

  const ErrorObject({required this.message, required this.code});
}

// -- protocol validation -------------------------------------------------- //

bool isSessionCompatible(
  SessionStruct session,
  ProposalRequiredNamespaces requiredNamespaces,
) {
  final sessionKeys = session.namespaces.keys.toList();
  final paramsKeys = requiredNamespaces.keys.toList();
  bool compatible = true;

  if (!hasOverlap(paramsKeys, sessionKeys)) return false;

  sessionKeys.forEach((key) {
    final sessionNamespace = session.namespaces[key]!;
    final accounts = sessionNamespace.accounts;
    final methods = sessionNamespace.methods;
    final events = sessionNamespace.events;
    final extension = sessionNamespace.extension;

    final chains = getAccountsChains(accounts);
    final requiredNamespace = requiredNamespaces[key]!;

    if (!hasOverlap(requiredNamespace.chains, chains) ||
        !hasOverlap(requiredNamespace.methods, methods) ||
        !hasOverlap(requiredNamespace.events, events)) {
      compatible = false;
    }

    if (compatible && extension != null) {
      extension.forEach((extensionNamespace) {
        final accounts = extensionNamespace.accounts;
        final methods = extensionNamespace.methods;
        final events = extensionNamespace.events;

        final chains = getAccountsChains(accounts);
        final overlap = requiredNamespace.extension?.any(
              (ext) =>
                  hasOverlap(ext.chains, chains) &&
                  hasOverlap(ext.methods, methods) &&
                  hasOverlap(ext.events, events),
            ) ??
            false;
        if (!overlap) compatible = false;
      });
    }
  });

  return compatible;
}

bool isValidChainId(String value) {
  if (value.contains(":")) {
    final split = value.split(":");
    return split.length == 2;
  }
  return false;
}

bool isValidAccountId(String value) {
  if (value.contains(":")) {
    final split = value.split(":");
    if (split.length == 3) {
      final chainId = split[0] + ":" + split[1];
      return split[2].isNotEmpty && isValidChainId(chainId);
    }
  }
  return false;
}

bool isValidUrl(String value) => Uri.tryParse(value) != null;

ErrorObject? isValidController(input, String method) {
  ErrorObject? error;
  if (input?.publicKey?.isEmpty ?? true) {
    error = getInternalError(
      InternalErrorKey.MISSING_OR_INVALID,
      context: '$method controller public key should be a string',
    );
  }

  return error;
}

ErrorObject? isValidExtension(
  dynamic namespace,
  String method,
) {
  if (namespace.extension != null) {
    if ((namespace is SessionNamespace && (namespace.extension!.isEmpty)) ||
        (namespace is ProposalRequiredNamespace &&
            (namespace.extension!.isEmpty))) {
      final error = getInternalError(
        InternalErrorKey.MISSING_OR_INVALID,
        context:
            '$method extension should be an array of namespaces, or omitted',
      );
      return ErrorObject(message: error.message, code: error.code);
    }
  }

  return null;
}

bool isValidNamespaceMethodsOrEvents(List<String>? input) {
  return input != null;
}

ErrorObject? isValidChains(
  String key,
  List<String> chains,
  String context,
) {
  ErrorObject? error;
  chains.forEach((chain) {
    if (error != null) return;
    if (!isValidChainId(chain) || !chain.contains(key)) {
      error = getSdkError(
        SdkErrorKey.UNSUPPORTED_CHAINS,
        context:
            '$context, chain $chain should be a string and conform to "namespace:chainId" format',
      );
    }
  });

  return error;
}

ErrorObject? isValidNamespaceChains(
  ProposalRequiredNamespaces namespaces,
  String method,
) {
  ErrorObject? error;
  namespaces.entries.forEach((entry) {
    final key = entry.key;
    final namespace = entry.value;
    if (error != null) return;
    final validChainsError =
        isValidChains(key, namespace.chains, '$method requiredNamespace');
    final validExtensionError = isValidExtension(namespace, method);
    if (validChainsError != null) {
      error = validChainsError;
    } else if (validExtensionError != null) {
      error = validExtensionError;
    } else if (namespace.extension != null) {
      namespace.extension!.forEach((extension) {
        if (error != null) return;
        final validChainsError =
            isValidChains(key, extension.chains, '$method extension');
        if (validChainsError != null) {
          error = validChainsError;
        }
      });
    }
  });

  return error;
}

ErrorObject? isValidAccounts(List<String> accounts, String context) {
  ErrorObject? error;
  if (accounts.isNotEmpty) {
    accounts.forEach((account) {
      if (error != null) return;

      if (!isValidAccountId(account)) {
        error = getSdkError(
          SdkErrorKey.UNSUPPORTED_ACCOUNTS,
          context:
              '$context, account $account should be a string and conform to "namespace:chainId:address" format',
        );
      }
    });
  } else {
    error = getSdkError(
      SdkErrorKey.UNSUPPORTED_ACCOUNTS,
      context:
          '$context, accounts should be an array of strings conforming to "namespace:chainId:address" format',
    );
  }

  return error;
}

ErrorObject? isValidNamespaceAccounts(
  SessionNamespaces input,
  String method,
) {
  ErrorObject? error;
  input.values.forEach((namespace) {
    if (error != null) return;
    final validAccountsError =
        isValidAccounts(namespace.accounts, '$method namespace');
    final validExtensionError = isValidExtension(namespace, method);
    if (validAccountsError != null) {
      error = validAccountsError;
    } else if (validExtensionError != null) {
      error = validExtensionError;
    } else if (namespace.extension != null) {
      namespace.extension!.forEach((extension) {
        if (error != null) return;
        final validAccountsError =
            isValidAccounts(extension.accounts, '$method extension');
        if (validAccountsError != null) {
          error = validAccountsError;
        }
      });
    }
  });

  return error;
}

ErrorObject? isValidActions(
  dynamic namespace,
  String context,
) {
  ErrorObject? error;
  if ((namespace is SessionBaseNamespace &&
          !isValidNamespaceMethodsOrEvents(namespace.methods)) ||
      (namespace is ProposalBaseRequiredNamespace &&
          !isValidNamespaceMethodsOrEvents(namespace.methods))) {
    error = getSdkError(
      SdkErrorKey.UNSUPPORTED_METHODS,
      context:
          '$context, methods should be an array of strings or empty array for no methods',
    );
  } else if ((namespace is SessionBaseNamespace &&
          !isValidNamespaceMethodsOrEvents(namespace.events)) ||
      (namespace is ProposalBaseRequiredNamespace &&
          !isValidNamespaceMethodsOrEvents(namespace.events))) {
    error = getSdkError(
      SdkErrorKey.UNSUPPORTED_EVENTS,
      context:
          '$context, events should be an array of strings or empty array for no events',
    );
  }

  return error;
}

ErrorObject? isValidNamespaceActions(
  dynamic input,
  String method,
) {
  ErrorObject? error;
  if (input is SessionNamespaces || input is ProposalRequiredNamespaces) {
    input.values.forEach((namespace) {
      if (error != null) return;
      final validActionsError = isValidActions(namespace, '$method, namespace');
      final validExtensionError = isValidExtension(namespace, method);
      if (validActionsError != null) {
        error = validActionsError;
      } else if (validExtensionError != null) {
        error = validExtensionError;
      } else if (namespace.extension != null) {
        namespace.extension!.forEach((value) {
          if (error != null) return;
          final validActionsError = isValidActions(value, '$method, extension');
          if (validActionsError != null) {
            error = validActionsError;
          }
        });
      }
    });
  }

  return error;
}

ErrorObject? isValidRequiredNamespaces(
  ProposalRequiredNamespaces? input,
  String method,
) {
  ErrorObject? error;
  if (input?.isNotEmpty ?? false) {
    final validActionsError = isValidNamespaceActions(input!, method);
    if (validActionsError != null) {
      error = validActionsError;
    }
    final validChainsError = isValidNamespaceChains(input, method);
    if (validChainsError != null) {
      error = validChainsError;
    }
  } else {
    error = getInternalError(
      InternalErrorKey.MISSING_OR_INVALID,
      context: '$method, requiredNamespaces should be an object with data',
    );
  }

  return error;
}

ErrorObject? isValidNamespaces(
  SessionNamespaces? input,
  String method,
) {
  ErrorObject? error;
  if (input?.isNotEmpty ?? false) {
    final validActionsError = isValidNamespaceActions(input!, method);
    if (validActionsError != null) {
      error = validActionsError;
    }
    final validAccountsError = isValidNamespaceAccounts(input, method);
    if (validAccountsError != null) {
      error = validAccountsError;
    }
  } else {
    error = getInternalError(
      InternalErrorKey.MISSING_OR_INVALID,
      context: '$method, namespaces should be an object with data',
    );
  }

  return error;
}

bool isValidRelay(RelayerProtocolOptions input) {
  return input.protocol.isNotEmpty;
}

bool isValidRelays(
  List<RelayerProtocolOptions>? input,
  bool optional,
) {
  bool valid = false;

  if (optional && (input?.isEmpty ?? true)) {
    valid = true;
  } else if (input?.isNotEmpty ?? false) {
    input!.forEach((relay) {
      valid = isValidRelay(relay);
    });
  }

  return valid;
}

bool isValidErrorReason(ErrorResponse? input) {
  if (input == null) return false;
  if (input.code == null) return false;
  if (input.message == null) return false;

  return true;
}

bool isValidNamespacesChainId(
  SessionNamespaces namespaces,
  String chainId,
) {
  if (!isValidChainId(chainId)) return false;
  final chains = getNamespacesChains(namespaces);
  if (!chains.contains(chainId)) return false;

  return true;
}

bool isValidNamespacesRequest(
  SessionNamespaces namespaces,
  String chainId,
  String method,
) {
  final methods = getNamespacesMethodsForChainId(namespaces, chainId);
  return methods.contains(method);
}

bool isValidNamespacesEvent(
  SessionNamespaces namespaces,
  String chainId,
  String eventName,
) {
  final events = getNamespacesEventsForChainId(namespaces, chainId);
  return events.contains(eventName);
}

ErrorObject? isConformingNamespaces(
  ProposalRequiredNamespaces requiredNamespaces,
  SessionNamespaces namespaces,
  String context,
) {
  ErrorObject? error;
  final requiredNamespaceKeys = requiredNamespaces.keys.toList();
  final namespaceKeys = namespaces.keys.toList();

  if (!hasOverlap(requiredNamespaceKeys, namespaceKeys)) {
    error = getInternalError(
      InternalErrorKey.NON_CONFORMING_NAMESPACES,
      context: '$context namespaces keys don\'t satisfy requiredNamespaces',
    );
  } else {
    requiredNamespaceKeys.forEach((key) {
      if (error != null) return;

      final requiredNamespaceChains = requiredNamespaces[key]!.chains;
      final namespaceChains = getAccountsChains(namespaces[key]!.accounts);

      if (!hasOverlap(requiredNamespaceChains, namespaceChains)) {
        error = getInternalError(
          InternalErrorKey.NON_CONFORMING_NAMESPACES,
          context:
              '$context namespaces accounts don\'t satisfy requiredNamespaces chains for $key',
        );
      } else if (!hasOverlap(
          requiredNamespaces[key]!.methods, namespaces[key]!.methods)) {
        error = getInternalError(
          InternalErrorKey.NON_CONFORMING_NAMESPACES,
          context:
              '$context namespaces methods don\'t satisfy requiredNamespaces methods for $key',
        );
      } else if (!hasOverlap(
          requiredNamespaces[key]!.events, namespaces[key]!.events)) {
        error = getInternalError(
          InternalErrorKey.NON_CONFORMING_NAMESPACES,
          context:
              '$context namespaces events don\'t satisfy requiredNamespaces events for $key',
        );
      } else if (requiredNamespaces[key]!.extension != null &&
          namespaces[key]!.extension == null) {
        error = getInternalError(
          InternalErrorKey.NON_CONFORMING_NAMESPACES,
          context:
              '$context namespaces extension doesn\'t satisfy requiredNamespaces extension for $key',
        );
      } else if (requiredNamespaces[key]!.extension != null &&
          namespaces[key]!.extension != null) {
        requiredNamespaces[key]!.extension!.forEach((namespace) {
          final methods = namespace.methods;
          final events = namespace.events;
          final chains = namespace.chains;

          if (error != null) return;
          final isOverlap = namespaces[key]!.extension!.any((namespace) {
            final accChains = getAccountsChains(namespace.accounts);
            return (hasOverlap(chains, accChains) &&
                hasOverlap(events, namespace.events) &&
                hasOverlap(methods, namespace.methods));
          });

          if (!isOverlap) {
            error = getInternalError(
              InternalErrorKey.NON_CONFORMING_NAMESPACES,
              context:
                  '$context namespaces extension doesn\'t satisfy requiredNamespaces extension for $key',
            );
          }
        });
      }
    });
  }

  return error;
}
