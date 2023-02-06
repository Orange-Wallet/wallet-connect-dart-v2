import 'dart:async';

import 'package:wallet_connect_dart_v2/wc_utils/jsonrpc/models/models.dart';

const DEFAULT_COMPLETER_TIMEOUT = Duration(minutes: 5);

extension CompleterExt on Completer {
  Timer expirer([Duration? duration]) {
    return Timer(duration ?? DEFAULT_COMPLETER_TIMEOUT, () {
      completeError(const ErrorResponse(code: -1, message: 'Timeout'));
    });
  }
}
