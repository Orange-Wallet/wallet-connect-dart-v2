import 'package:wallet_connect_dart_v2/sign/sign-client/session/models.dart';

List<String> getAccountsChains(List<String> accounts) {
  final List<String> chains = [];
  accounts.forEach((account) {
    final split = account.split(":");
    chains.add('${split[0]}:${split[1]}');
  });

  return chains;
}

List<String> getNamespacesChains(SessionNamespaces namespaces) {
  final List<String> chains = [];
  namespaces.values.forEach((namespace) {
    chains.addAll(getAccountsChains(namespace.accounts));
    if (namespace.extension != null) {
      namespace.extension!.forEach((extension) {
        chains.addAll(getAccountsChains(extension.accounts));
      });
    }
  });

  return chains;
}

List<String> getNamespacesMethodsForChainId(
  SessionNamespaces namespaces,
  String chainId,
) {
  final List<String> methods = [];
  namespaces.values.forEach((namespace) {
    final chains = getAccountsChains(namespace.accounts);
    if (chains.contains(chainId)) methods.addAll(namespace.methods);
    if (namespace.extension != null) {
      namespace.extension!.forEach((extension) {
        final extensionChains = getAccountsChains(extension.accounts);
        if (extensionChains.contains(chainId)) {
          methods.addAll(extension.methods);
        }
      });
    }
  });

  return methods;
}

List<String> getNamespacesEventsForChainId(
  SessionNamespaces namespaces,
  String chainId,
) {
  final List<String> events = [];
  namespaces.values.forEach((namespace) {
    final chains = getAccountsChains(namespace.accounts);
    if (chains.contains(chainId)) events.addAll(namespace.events);
    if (namespace.extension != null) {
      namespace.extension!.forEach((extension) {
        final extensionChains = getAccountsChains(extension.accounts);
        if (extensionChains.contains(chainId)) events.addAll(extension.events);
      });
    }
  });

  return events;
}
